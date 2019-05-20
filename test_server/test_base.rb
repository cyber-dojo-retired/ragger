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

  def ready?
    traffic_light.ready?
  end

  def sha
    traffic_light.sha
  end

  def colour(image_name, id, stdout, stderr, status)
    @result = traffic_light.colour(image_name, id, stdout, stderr, status)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_sha(string)
    assert_equal 40, string.size
    string.each_char do |ch|
      assert "0123456789abcdef".include?(ch)
    end
  end

  def red?
    colour?('red')
  end

  def amber?
    colour?('amber')
  end

  def green?
    colour?('green')
  end

  def colour?(expected)
    @result === expected
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    hex_test_id[0..5]
  end

end
