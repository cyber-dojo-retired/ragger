require_relative 'hex_mini_test'
require_relative '../src/external'
require_relative '../src/traffic_light'
require 'stringio'

class TestBase < HexMiniTest

  def external
    @external ||= External.new
  end

  def traffic_light
    TrafficLight.new(external)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def ready?
    traffic_light.ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def sha
    traffic_light.sha
  end

  def assert_sha(string)
    assert_equal 40, string.size
    string.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def colour(image_name, id, stdout, stderr, status)
    @result = traffic_light.colour(image_name, id, stdout, stderr, status)
  end

  def assert_red
    assert colour?('red')
  end

  def assert_amber
    assert colour?('amber')
  end

  def assert_green
    assert colour?('green')
  end

  def colour?(expected)
    @result === expected
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_log
    @log = ''
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('', 'w')
      yield
      @log = $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    hex_test_id[0..5]
  end

end
