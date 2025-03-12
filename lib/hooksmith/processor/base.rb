# frozen_string_literal: true

module Hooksmith
  module Processor
    # Base class for all webhook processors.
    #
    # Processors should inherit from this class and implement the process! method.
    #
    # @abstract
    class Base
      # @return [Hash] the payload for the webhook.
      attr_reader :payload

      # Initializes the processor with a payload.
      #
      # @param payload [Hash] the webhook payload.
      def initialize(payload)
        @payload = payload
      end

      # Checks if the processor can handle the payload.
      # Override this method in subclasses if conditional processing is needed.
      #
      # @param payload [Hash] the webhook payload.
      # @return [Boolean] true if the processor can handle the payload.
      def can_handle?(_payload)
        true
      end

      # Process the webhook.
      # Must be implemented by subclasses.
      #
      # @raise [NotImplementedError] if not implemented.
      def process!
        raise NotImplementedError, 'Implement process! in your processor'
      end
    end
  end
end
