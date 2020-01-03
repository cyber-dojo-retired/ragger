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

  # - - - - - - - - - - - - - - - - -

  test '6A4', %w(
  when image-name is well-formed but non-existent,
  then runner raises,
  and the colour is mapped to faulty,
  and a diagnostic is added to the json result
  ) do
    #externals.instance_exec { @runner = Object.new }
    image_name = 'anything-not-cached'
    stdout = 's1'
    stderr = 't4'
    status = '0'
    with_captured_stdout_stderr {
      colour(image_name, id, stdout, stderr, status)
    }
    assert_faulty
    #assert @stdout.start_with?('red_amber_green lambda error mapped to :faulty')
    #puts '~~~~~~~~~~'
    #puts @result
    #puts '~~~~~~~~~~'
    #puts @stdout
    #puts '~~~~~~~~~~'
  end

  # - - - - - - - - - - - - - - - - -

  test '5A3', %w(
  when rag-lambda has an eval exception,
  then colour is mapped to faulty,
  and a diagnostic is added to the json result
  ) do
    assert_faulty_error("undefined local variable or method `sdf'",
      <<~RUBY
      sdf
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A4', %w(
  when rag-lambda has a call exception,
  then the colour is mapped to faulty,
  and a diagnostic is added to the json result
  ) do
    assert_faulty_error('wibble',
      <<~RUBY
      lambda { |stdout, stderr, status|
        raise ArgumentError.new('wibble')
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A5', %w(
  when the rag-lambda returns non red/amber/green,
  then the colour is mapped to faulty,
  and a diagnostic is added to the json result
  ) do
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
  %w( too few parameters is a call-exception, mapped to colour faulty ) do
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
  %w( too many parameters is a call-exception, mapped to colour faulty ) do
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
    image_name = PythonPytest::IMAGE_NAME
    stdout = 's1'
    stderr = 's2'
    status = '0'
    with_captured_stdout_stderr {
      colour(image_name, id, stdout, stderr, status)
    }
    HttpStub.unstub_request
    #puts JSON.pretty_generate(@result)
    #puts '~~~~~~~~~~'
    #puts @result
    #puts '~~~~~~~~~~'
    #puts @stdout
    #puts '~~~~~~~~~~'
    assert_faulty
    assert_equal image_name, @result['diagnostic']['image_name'], :image_name
    assert_equal id, @result['diagnostic']['id'], :id
    assert_equal stdout, @result['diagnostic']['stdout'], :stdout
    assert_equal stderr, @result['diagnostic']['stderr'], :stderr
    assert_equal status, @result['diagnostic']['status'], :status
    #assert @result['diagnostic']['exception'].include?(rag_src), :exception
    #assert_equal 'rag_lambda raised an exception', @result['diagnostic']['message']
    assert spy.spied?(expected)
  end

end
