# frozen_string_literal: true

require 'hooksmith/version'
require 'hooksmith/configuration'
require 'hooksmith/dispatcher'
require 'hooksmith/logger'
require 'hooksmith/processor/base'
require 'hooksmith/railtie' if defined?(Rails)

# Main entry point for the Hooksmith gem.
#
# @example Basic usage:
#   Hooksmith.configure do |config|
#     config.provider(:stripe) do |stripe|
#       stripe.register(:charge_succeeded, MyStripeProcessor)
#     end
#   end
#
#   Hooksmith::Dispatcher.new(provider: :stripe, event: :charge_succeeded, payload: payload).run!
#
module Hooksmith
  # Returns the configuration instance.
  # @return [Configuration] the configuration instance.
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Yields the configuration to a block.
  # @yieldparam config [Configuration]
  def self.configure
    yield(configuration)
  end

  # Returns the gem's logger instance.
  # @return [Logger] the logger instance.
  def self.logger
    Logger.instance
  end
end
