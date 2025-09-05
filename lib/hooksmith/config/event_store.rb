# frozen_string_literal: true

module Hooksmith
  module Config
    # EventStore holds settings for optional event persistence.
    class EventStore
      # Whether persistence is enabled.
      attr_accessor :enabled
      # Class name of the model used to persist events. Must respond to .create!(attrs)
      attr_accessor :model_class_name
      # Proc to map provider/event/payload to attributes persisted
      attr_accessor :mapper
      # When to record: :before, :after, or :both
      attr_accessor :record_timing

      def initialize
        @enabled = false
        # No default model in the gem; applications should provide their own model
        @model_class_name = nil
        @record_timing = :before
        @mapper = default_mapper
      end

      def model_class
        return nil if model_class_name.nil?

        Object.const_get(model_class_name)
      rescue NameError
        nil
      end

      private

      def default_mapper
        lambda do |provider:, event:, payload:|
          now = Time.respond_to?(:current) ? Time.current : Time.now
          {
            provider: provider.to_s,
            event: event.to_s,
            payload:,
            received_at: now
          }
        end
      end
    end
  end
end
