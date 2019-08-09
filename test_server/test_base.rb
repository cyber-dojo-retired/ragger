require_relative 'hex_mini_test'
require_relative '../src/external'
require_relative '../src/traffic_light'

class TestBase < HexMiniTest

  def external
    @external ||= External.new
  end

  def traffic_light
    TrafficLight.new(external)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sha
    traffic_light.sha
  end

  def ready?
    traffic_light.ready?
  end

  def alive?
    traffic_light.alive?
  end

  def colour(image_name, id, stdout, stderr, status)
    @result = traffic_light.colour(image_name, id, stdout, stderr, status)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_sha(string)
    assert_equal 40, string.size
    string.each_char do |ch|
      assert '0123456789abcdef'.include?(ch)
    end
  end

  def assert_red
    assert_colour('red')
  end

  def assert_amber
    assert_colour('amber')
  end

  def assert_green
    assert_colour('green')
  end

  def assert_colour(expected)
    assert_equal expected, @result
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    hex_test_id[0..5]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def with_captured_stdout_stderr
    begin
      old_stdout = $stdout
      old_stderr = $stderr
      $stdout = StringIO.new('', 'w')
      $stderr = StringIO.new('', 'w')
      yield
    ensure
      @stderr = $stderr.string
      @stdout = $stdout.string
      $stderr = old_stderr
      $stdout = old_stdout
    end
  end

end
