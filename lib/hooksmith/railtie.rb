# frozen_string_literal: true

if defined?(Rails)
  module Hooksmith
    # Railtie integration for Hooksmith.
    #
    # This file allows Hooksmith to integrate seamlessly with a Rails application.
    class Railtie < Rails::Railtie
      initializer 'hooksmith.configure_rails_initialization' do |_|
        if defined?(Rails.logger) && Rails.logger
          Hooksmith::Logger.instance.instance_variable_set(:@logger, Rails.logger)
        end
      end
    end
  end
end
