# frozen_string_literal: true

require 'test_helper'

# ProcessorBaseTest
class ProcessorBaseTest < Minitest::Test
  def test_process_not_implemented
    processor = Hooksmith::Processor::Base.new({})
    assert_raises(NotImplementedError) { processor.process! }
  end
end
