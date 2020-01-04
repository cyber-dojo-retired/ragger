require_relative 'test_base'
require_relative 'data/python_pytest'
require_relative 'http_stub'
require_relative 'stdout_log_spy'

class ColourTest < TestBase

  def self.id58_prefix
    'm60'
  end

  # - - - - - - - - - - - - - - - - -

  test '6A1', %w(
  for a straight red only the colour is returned
  ) do
    result = colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_RED, '', '0')
    assert_equal({'colour' => 'red'}, result)
  end

  test '6A2', %w(
  for a straight amber only the colour is returned
  ) do
    result = colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_AMBER, '', '0')
    assert_equal({'colour' => 'amber'}, result)
  end

  test '6A3', %w(
  for a straight green only the colour is returned
  ) do
    result = colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_GREEN, '', '0')
    assert_equal({'colour' => 'green'}, result)
  end

  # - - - - - - - - - - - - - - - - -

  test '6A4', %w(
  when image-name is well-formed but non-existent,
  then runner raises,
  and the colour is mapped to faulty,
  and a diagnostic is added to the json result
  ) do
    image_name = 'anything-not-cached'
    assert_faulty(image_name, id, 'o1', 'e3', '0') do |rd,od|
      message = 'runner.run_cyber_dojo_sh() raised an exception'
      assert_tri_equal message, rd['message'], od['message']
      assert_nil rd['lambda']
      assert_nil od['lambda']
      ex_rd = rd['exception']
      ex_od = od['exception']
      assert_equal ex_rd, ex_od
      assert ex_rd.is_a?(String)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '5A3', %w(
  when rag-lambda has an eval exception,
  then colour is mapped to faulty,
  and a diagnostic is added to the json result
  ) do
    stub =
      <<~RUBY
      sdf
      RUBY

    assert_lambda_stub_faulty(stub) do |rd,od|
      expected_message = 'eval(lambda) raised an exception'
      expected_exception = "undefined local variable or method `sdf' for"
      assert_tri_equal expected_message, rd['message'], od['message']
      assert_tri_equal stub, rd['lambda'], od['lambda']
      assert od['exception'].start_with?(expected_exception), od
      assert rd['exception'].start_with?(expected_exception), rd
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '5A4', %w(
  when rag-lambda has a call exception,
  then the colour is mapped to faulty,
  and a diagnostic is added to the json result
  ) do
    stub =
      <<~RUBY
      lambda { |stdout, stderr, status|
        raise ArgumentError.new('wibble')
      }
      RUBY
    assert_lambda_stub_faulty(stub) do |rd,od|
      expected_message = 'calling the lambda raised an exception'
      expected_exception = 'wibble'
      assert_tri_equal expected_message, rd['message'], od['message']
      assert_tri_equal stub, rd['lambda'], od['lambda']
      assert_tri_equal expected_exception, rd['exception'], od['exception']
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '5A5', %w(
  when the rag-lambda returns non red/amber/green,
  then the colour is mapped to faulty,
  and a diagnostic is added to the json result
  ) do
    stub =
    <<~RUBY
    lambda { |stdout, stderr, status|
      return :orange
    }
    RUBY
    assert_lambda_stub_faulty(stub) do |rd,od|
      expected_message = "lambda returned 'orange' which is not 'red'|'amber'|'green'"
      assert_tri_equal expected_message, rd['message'], od['message']
      assert_tri_equal stub, rd['lambda'], od['lambda']
      assert_nil rd['exception']
      assert_nil od['exception']
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '5A6', %w(
    too few parameters is a call-exception, mapped to colour faulty
  ) do
    stub =
    <<~RUBY
    lambda { |stdout, stderr|
      return :red
    }
    RUBY
    assert_lambda_stub_faulty(stub) do |rd,od|
      expected_message = 'calling the lambda raised an exception'
      expected_exception = 'wrong number of arguments (given 3, expected 2)'
      assert_tri_equal expected_message, rd['message'], od['message']
      assert_tri_equal stub, rd['lambda'], od['lambda']
      assert_tri_equal expected_exception, rd['exception'], od['exception']
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '5A7',
  %w( too many parameters is a call-exception, mapped to colour faulty ) do
    stub =
    <<~RUBY
    lambda { |stdout, stderr, status, extra|
      return :red
    }
    RUBY
    assert_lambda_stub_faulty(stub) do |rd,od|
      expected_message = 'calling the lambda raised an exception'
      expected_exception = 'wrong number of arguments (given 3, expected 4)'
      assert_tri_equal expected_message, rd['message'], od['message']
      assert_tri_equal stub, rd['lambda'], od['lambda']
      assert_tri_equal expected_exception, rd['exception'], od['exception']
    end
  end

  private

  include Test::Data

  def assert_lambda_stub_faulty(rag_src)
    @externals = Externals.new({ 'http' => HttpStub })
    HttpStub.stub_request({
      'run_cyber_dojo_sh' => {
        'stdout' => {
          'content' => rag_src
        }
      }
    })
    assert_faulty(PythonPytest::IMAGE_NAME, id, 'o34', 'e67', '3') do |rd,od|
      yield rd,od
    end
  end

  # - - - - - - - - - - - - - - - - -

  def assert_faulty(image_name, id, stdout, stderr, status)
    with_captured_stdout_stderr {
      colour(image_name, id, stdout, stderr, status)
    }
    assert_equal '', @stderr
    json_stdout = JSON.parse(@stdout)

    assert_equal 'faulty', @result.delete('colour'), :colour_result
    assert_equal 'faulty', json_stdout.delete('colour'), :colour_stdout

    assert_equal image_name, @result['diagnostic'].delete('image_name'), :RESULT_image_name
    assert_equal image_name, json_stdout['diagnostic'].delete('image_name'), :STDOUT_image_name

    assert_equal id, @result['diagnostic'].delete('id'), :RESULT_id
    assert_equal id, json_stdout['diagnostic'].delete('id'), :STDOUT_id

    assert_equal stdout, @result['diagnostic'].delete('stdout'), :RESULT_stdout
    assert_equal stdout, json_stdout['diagnostic'].delete('stdout'), :STDOUT_stdout

    assert_equal stderr, @result['diagnostic'].delete('stderr'), :RESULT_stderr
    assert_equal stderr, json_stdout['diagnostic'].delete('stderr'), :STDOUT_stderr

    assert_equal status, @result['diagnostic'].delete('status'), :RESULT_status
    assert_equal status, json_stdout['diagnostic'].delete('status'), :STDOUT_status

    yield @result['diagnostic'], json_stdout['diagnostic']
  end

  # - - - - - - - - - - - - - - - - -

  def assert_tri_equal(expected, from_result, from_stdout)
    assert_equal expected, from_result, :result
    assert_equal expected, from_stdout, :stdout
  end

end
