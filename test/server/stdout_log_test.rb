require_relative 'test_base'
require_relative '../require_src'
require_src 'stdout_log'

class StdoutLogTest < TestBase

  def self.id58_prefix
    'CD476'
  end

  # - - - - - - - - - - - - - - - -

  test '20C',
  'logging a string message send it directly to stdout' do
    stdout = captured_stdout {
      StdoutLog.new << 'Hello'
    }
    assert_equal 'Hello', stdout
  end

  # - - - - - - - - - - - - - - - -

  def captured_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('', 'w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

end
