# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'rack/test'
require 'json'
require 'hooksmith'

# Helper to allow "test 'name' do" syntax in Minitest if not using ActiveSupport::TestCase.
unless respond_to?(:test)
  module Minitest
    # Minitest::Test
    class Test
      def self.test(name, &block)
        define_method("test_#{name.gsub(/\s+/, '_')}", &block)
      end
    end
  end
end
