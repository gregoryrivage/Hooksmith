# frozen_string_literal: true

require 'test_helper'

# LoggerTest
class LoggerTest < Minitest::Test
  def setup
    @logger_instance = Hooksmith::Logger.instance
    @log_output = StringIO.new
    @original_logger = @logger_instance.instance_variable_get(:@logger)
    test_logger = ::Logger.new(@log_output)
    test_logger.level = ::Logger::DEBUG
    @logger_instance.instance_variable_set(:@logger, test_logger)
  end

  def teardown
    @logger_instance.instance_variable_set(:@logger, @original_logger)
  end

  def test_info_logging
    @logger_instance.info('info message')
    @log_output.rewind
    output = @log_output.read
    assert_match(/INFO -- : info message/, output)
  end

  def test_warn_logging
    @logger_instance.warn('warn message')
    @log_output.rewind
    output = @log_output.read
    assert_match(/WARN -- : warn message/, output)
  end

  def test_error_logging
    @logger_instance.error('error message')
    @log_output.rewind
    output = @log_output.read
    assert_match(/ERROR -- : error message/, output)
  end

  def test_debug_logging
    @logger_instance.debug('debug message')
    @log_output.rewind
    output = @log_output.read
    assert_match(/DEBUG -- : debug message/, output)
  end
end
