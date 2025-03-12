# frozen_string_literal: true

require 'test_helper'

# RailtieTest
class RailtieTest < Minitest::Test
  if defined?(Rails)
    def setup
      @original_logger = Rails.logger
      fake_output = StringIO.new
      fake_logger = ::Logger.new(fake_output)
      # Redéfinir Rails.logger temporairement.
      Rails.singleton_class.send(:define_method, :logger) { fake_logger }
      # Simuler l'initialisation de la Railtie.
      Hooksmith::Railtie.new
    end

    def teardown
      Rails.singleton_class.send(:define_method, :logger) { @original_logger }
    end

    def test_railtie_sets_logger
      assert_equal Rails.logger, Hooksmith::Logger.instance.instance_variable_get(:@logger)
    end
  else
    def test_railtie_not_defined
      skip 'Rails non défini, test Railtie ignoré'
    end
  end
end
