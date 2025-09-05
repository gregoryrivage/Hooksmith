# frozen_string_literal: true

module Hooksmith
  # Records webhook events to a configurable persistence model.
  #
  # This recorder is resilient: failures to persist are logged and do not
  # impact the main processing flow.
  module EventRecorder
    module_function

    # Record an event if the event store is enabled.
    #
    # @param provider [Symbol, String]
    # @param event [Symbol, String]
    # @param payload [Hash]
    # @param timing [Symbol] one of :before or :after
    def record!(provider:, event:, payload:, timing: :before)
      config = Hooksmith.configuration.event_store_config
      return unless config.enabled
      return unless record_for_timing?(config, timing)

      model_class = config.model_class
      unless model_class
        Hooksmith.logger.warn("Event store enabled but model '#{config.model_class_name}' not found")
        return
      end

      attributes = safe_map(config, provider:, event:, payload:)
      model_class.create!(attributes)
    rescue StandardError => e
      Hooksmith.logger.error("Failed to record webhook event: #{e.message}")
    end

    # Determine whether to record depending on the configured timing.
    def record_for_timing?(config, timing)
      case config.record_timing
      when :both then true
      when :before then timing == :before
      when :after then timing == :after
      end
    end
    private_class_method :record_for_timing?

    # Safely map attributes using the configured mapper.
    def safe_map(config, provider:, event:, payload:)
      mapper = config.mapper
      mapper.call(provider:, event:, payload:)
    rescue StandardError => e
      Hooksmith.logger.error("Event mapper raised: #{e.message}")
      {}
    end
    private_class_method :safe_map
  end
end
