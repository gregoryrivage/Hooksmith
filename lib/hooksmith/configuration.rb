# frozen_string_literal: true

# Provides a DSL for registering webhook processors by provider and event.
#
module Hooksmith
  # Configuration holds the registry of all processors.
  class Configuration
    # @return [Hash] a registry mapping provider symbols to arrays of processor entries.
    attr_reader :registry

    def initialize
      # Registry structure: { provider_symbol => [{ event: event_symbol, processor: ProcessorClass }, ...] }
      @registry = Hash.new { |hash, key| hash[key] = [] }
    end

    # Groups registrations under a specific provider.
    #
    # @param provider_name [Symbol, String] the provider name (e.g., :stripe)
    # @yield [ProviderConfig] a block yielding a ProviderConfig object
    def provider(provider_name)
      provider_config = ProviderConfig.new(provider_name)
      yield(provider_config)
      registry[provider_name.to_sym].concat(provider_config.entries)
    end

    # Direct registration of a processor.
    #
    # @param provider [Symbol, String] the provider name
    # @param event [Symbol, String] the event name
    # @param processor_class_name [String] the processor class name
    def register_processor(provider, event, processor_class_name)
      registry[provider.to_sym] << { event: event.to_sym, processor: processor_class_name }
    end

    # Returns all processor entries for a given provider and event.
    #
    # @param provider [Symbol, String] the provider name
    # @param event [Symbol, String] the event name
    # @return [Array<Hash>] the array of matching entries.
    def processors_for(provider, event)
      registry[provider.to_sym].select { |entry| entry[:event] == event.to_sym }
    end
  end

  # ProviderConfig is used internally by the DSL to collect processor registrations.
  class ProviderConfig
    # @return [Symbol, String] the provider name.
    attr_reader :provider
    # @return [Array<Hash>] list of entries registered.
    attr_reader :entries

    def initialize(provider)
      @provider = provider
      @entries = []
    end

    # Registers a processor for a specific event.
    #
    # @param event [Symbol, String] the event name.
    # @param processor_class_name [String] the processor class name.
    def register(event, processor_class_name)
      entries << { event: event.to_sym, processor: processor_class_name }
    end
  end
end
