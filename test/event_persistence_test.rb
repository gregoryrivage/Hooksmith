# frozen_string_literal: true

require 'test_helper'

# Fausse classe modèle pour tester la persistance sans DB.
class ::FakeEventModel
  class << self
    def reset!
      @created_records = []
    end

    def create!(attrs)
      @created_records ||= []
      @created_records << attrs
      true
    end

    def created_records
      @created_records ||= []
    end
  end
end

# Test de la configuration et de l'enregistrement des évènements
class EventPersistenceTest < Minitest::Test
  def setup
    Hooksmith.configuration.registry.clear
    FakeEventModel.reset!
    # Configurer l'event store pour utiliser le faux modèle
    Hooksmith.configuration.event_store do |store|
      store.enabled = true
      store.model_class_name = 'FakeEventModel'
      store.record_timing = :both
      store.mapper = lambda { |provider:, event:, payload:|
        {
          provider: provider.to_s,
          event: event.to_s,
          payload:,
          received_at: (Time.respond_to?(:current) ? Time.current : Time.now)
        }
      }
    end
  end

  # Fake processor for testing
  class ::NoopProcessor < Hooksmith::Processor::Base
    def process!
      'ok'
    end
  end

  def test_records_before_and_after
    Hooksmith.configuration.register_processor(:x, :y, 'NoopProcessor')
    payload = { a: 1 }
    result = Hooksmith::Dispatcher.new(provider: :x, event: :y, payload:).run!
    assert_equal 'ok', result
    assert_equal 2, FakeEventModel.created_records.size
    before_attrs, after_attrs = FakeEventModel.created_records
    assert_equal 'x', before_attrs[:provider]
    assert_equal 'y', before_attrs[:event]
    assert_equal payload, before_attrs[:payload]
    assert before_attrs[:received_at]
    assert_equal 'x', after_attrs[:provider]
  end

  def test_disabled_event_store_does_not_record
    Hooksmith.configuration.event_store { |s| s.enabled = false }
    Hooksmith.configuration.register_processor(:x, :y, 'NoopProcessor')
    Hooksmith::Dispatcher.new(provider: :x, event: :y, payload: {}).run!
    assert_equal 0, FakeEventModel.created_records.size
  end

  def test_missing_model_is_logged_and_ignored
    Hooksmith.configuration.event_store do |s|
      s.enabled = true
      s.model_class_name = 'MissingModelClassName'
      s.record_timing = :before
    end
    Hooksmith.configuration.register_processor(:x, :y, 'NoopProcessor')
    Hooksmith::Dispatcher.new(provider: :x, event: :y, payload: {}).run!
    # Nothing recorded
    assert_equal 0, FakeEventModel.created_records.size
  end
end
