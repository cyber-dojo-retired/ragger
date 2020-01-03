require_relative '../id58_test_base'
require_relative '../require_src'
require_src 'externals'
require_src 'traffic_light'

class TestBase < Id58TestBase

  def externals
    @externals ||= Externals.new
  end

  def traffic_light
    @traffic_light ||= TrafficLight.new(externals)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def sha?(s)
    s.is_a?(String) &&
      s.size === 40 &&
        s.chars.all?{|ch| '0123456789abcdef'.include?(ch) }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def colour(image_name, id, stdout, stderr, status)
    @result = traffic_light.colour(image_name, id, stdout, stderr, status)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_red
    assert_colour('red')
  end

  def assert_amber
    assert_colour('amber')
  end

  def assert_green
    assert_colour('green')
  end

  def assert_faulty
    assert_colour('faulty')
  end

  def assert_colour(expected)
    assert_equal(expected, @result['colour'])
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -

  def id
    id58[0..5]
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
