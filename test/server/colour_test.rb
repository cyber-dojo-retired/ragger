require_relative 'test_base'
require_relative 'data/python_pytest'
require_relative 'http_stub'
require_relative 'stdout_log_spy'

class ColourTest < TestBase

  def self.id58_prefix
    'm60'
  end

  # - - - - - - - - - - - - - - - - -

  test '6A1', 'red' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_RED, '', '0')
    assert_red
  end

  test '6A2', 'amber' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_AMBER, '', '0')
    assert_amber
  end

  test '6A3', 'green' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_GREEN, '', '0')
    assert_green
  end

  test '6A4', 'well-formed but non-existent image_name' do
    externals.instance_exec { @runner = Object.new }
    image_name = 'anything-not-cached'
    with_captured_stdout_stderr {
      colour(image_name, id, '', '', '0')
    }
    assert @stdout.start_with?('red_amber_green lambda error mapped to :faulty')
    assert_faulty
  end

  # - - - - - - - - - - - - - - - - -

  test '5A3',
  %w( faulty for syntax-error ) do
    assert_faulty_error("undefined local variable or method `sdf'",
      <<~RUBY
      sdf
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A4',
  %w( faulty for explicit raise ) do
    assert_faulty_error('wibble',
      <<~RUBY
      lambda { |stdout, stderr, status|
        raise ArgumentError.new('wibble')
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A5',
  %w( faulty for non red/amber/green ) do
    assert_faulty_error('orange',
      <<~RUBY
      lambda { |stdout, stderr, status|
        return :orange
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A6',
  %w( faulty for too few parameters ) do
    assert_faulty_error('wrong number of arguments (given 3, expected 2)',
      <<~RUBY
      lambda { |stdout, stderr|
        return :red
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A7',
  %w( faulty for too many parameters ) do
    assert_faulty_error('wrong number of arguments (given 3, expected 4)',
      <<~RUBY
      lambda { |stdout, stderr, status, extra|
        return :red
      }
      RUBY
    )
  end

  private

  include Test::Data

  def assert_faulty_error(expected, rag_src)
    spy = StdoutLogSpy.new
    @externals = Externals.new({ 'http' => HttpStub, 'log' => spy })
    HttpStub.stub_request({
      'run_cyber_dojo_sh' => {
        'stdout' => {
          'content' => rag_src
        }
      }
    })
    colour(PythonPytest::IMAGE_NAME, id, '', '', '0')
    HttpStub.unstub_request
    assert_faulty
    assert spy.spied?(expected)
  end

end
