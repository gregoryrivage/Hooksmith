# frozen_string_literal: true

require 'logger'
require 'singleton'

module Hooksmith
  # A lightweight logger for Hooksmith.
  #
  # Uses Ruby's standard Logger under the hood and can be configured to use Rails.logger.
  class Logger
    include Singleton

    # Initializes the logger.
    def initialize
      @logger = ::Logger.new($stdout)
      @logger.level = ::Logger::INFO
    end

    # Logs an info message.
    #
    # @param msg [String] the message.
    def info(msg)
      @logger.info(msg)
    end

    # Logs a warning message.
    #
    # @param msg [String] the message.
    def warn(msg)
      @logger.warn(msg)
    end

    # Logs an error message.
    #
    # @param msg [String] the message.
    def error(msg)
      @logger.error(msg)
    end

    # Logs a debug message.
    #
    # @param msg [String] the message.
    def debug(msg)
      @logger.debug(msg)
    end
  end
end
