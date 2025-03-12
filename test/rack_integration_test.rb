# frozen_string_literal: true

require 'test_helper'

# Application Rack simple intégrant Hooksmith.
class HooksmithRackApp
  def call(env)
    request = Rack::Request.new(env)
    begin
      payload = JSON.parse(request.body.read, symbolize_names: true)
      provider = payload.delete(:provider)
      event    = payload.delete(:event)
      result   = Hooksmith::Dispatcher.new(provider:, event:, payload:).run!
      [200, { 'Content-Type' => 'application/json' }, [{ result: }.to_json]]
    rescue StandardError => e
      [500, { 'Content-Type' => 'application/json' }, [{ error: e.message }.to_json]]
    end
  end
end

# RackIntegrationTest
class RackIntegrationTest < Minitest::Test
  include Rack::Test::Methods

  def app
    HooksmithRackApp.new
  end

  # Processor qui renvoie une valeur lors du traitement.
  class TestProcessor < Hooksmith::Processor::Base
    def can_handle?(_payload)
      true
    end

    def process!
      'processed'
    end
  end

  # Processor simulant une erreur.
  class ErrorProcessor < Hooksmith::Processor::Base
    def can_handle?(_payload)
      true
    end

    def process!
      raise StandardError, 'processing failed'
    end
  end

  def setup
    Hooksmith.configuration.registry.clear
  end

  def test_rack_endpoint_success
    Hooksmith.configuration.register_processor(:test, :event, TestProcessor)
    payload = { provider: 'test', event: 'event', key: 'value' }
    post '/', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
    assert_equal 200, last_response.status
    response = JSON.parse(last_response.body)
    assert_equal 'processed', response['result']
  end

  def test_rack_endpoint_error
    Hooksmith.configuration.register_processor(:test, :event, ErrorProcessor)
    payload = { provider: 'test', event: 'event', key: 'value' }
    post '/', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
    assert_equal 500, last_response.status
    response = JSON.parse(last_response.body)
    assert_match(/processing failed/, response['error'])
  end
end
