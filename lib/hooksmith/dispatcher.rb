# frozen_string_literal: true

module Hooksmith
  # Dispatcher routes incoming webhook payloads to the appropriate processor.
  #
  # @example Dispatch a webhook event:
  #   Hooksmith::Dispatcher.new(provider: :stripe, event: :charge_succeeded, payload: payload).run!
  #
  class Dispatcher
    # Initializes a new Dispatcher.
    #
    # @param provider [Symbol, String] the provider (e.g., :stripe)
    # @param event [Symbol, String] the event (e.g., :charge_succeeded)
    # @param payload [Hash] the webhook payload data.
    def initialize(provider:, event:, payload:)
      @provider = provider.to_sym
      @event    = event.to_sym
      @payload  = payload
    end

    # Runs the dispatcher.
    #
    # Instantiates each processor registered for the given provider and event,
    # then selects the ones that can handle the payload using the can_handle? method.
    # - If no processors qualify, logs a warning.
    # - If more than one qualifies, raises MultipleProcessorsError.
    # - Otherwise, processes the event with the single matching processor.
    #
    # @raise [MultipleProcessorsError] if multiple processors qualify.
    def run!
      # Fetch all processors registered for this provider and event.
      entries = Hooksmith.configuration.processors_for(@provider, @event)

      # Instantiate each processor and filter by condition.
      matching_processors = entries.map do |entry|
        processor = entry[:processor].new(@payload)
        processor if processor.can_handle?(@payload)
      end.compact

      if matching_processors.empty?
        Hooksmith.logger.warn("No processor registered for #{@provider} event #{@event} could handle the payload")
        return
      end

      # If more than one processor qualifies, raise an error.
      raise MultipleProcessorsError.new(@provider, @event, @payload) if matching_processors.size > 1

      # Exactly one matching processor.
      matching_processors.first.process!
    rescue StandardError => e
      Hooksmith.logger.error("Error processing #{@provider} event #{@event}: #{e.message}")
      raise e
    end
  end

  # Raised when multiple processors can handle the same event.
  class MultipleProcessorsError < StandardError
    # Initializes the error with details about the provider, event, and payload.
    #
    # @param provider [Symbol] the provider name.
    # @param event [Symbol] the event name.
    # @param payload [Hash] the webhook payload.
    def initialize(provider, event, payload)
      super("Multiple processors found for #{provider} event #{event}. Payload: #{payload}")
    end
  end
end
