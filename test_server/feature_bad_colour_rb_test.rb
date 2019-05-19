require_relative 'http_stub'
require_relative 'python_pytest'
require_relative 'test_base'

class FeatureBadColourRbTest < TestBase

  def self.hex_prefix
    'F6D'
  end

  # - - - - - - - - - - - - - - - - -

  test '5A3',
  %w( colour lambda syntax-error recorded in log ) do
    assert_stderr("undefined local variable or method `sdf'",
      <<~RUBY
      sdf
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A4',
  %w( colour lambda explicit raise recorded in log ) do
    assert_stderr('wibble',
      <<~RUBY
      lambda { |stdout, stderr, status|
        raise ArgumentError.new('wibble')
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A5',
  %w( colour lambda returning non red/amber/green recorded in log ) do
    assert_stderr('orange',
      <<~RUBY
      lambda { |stdout, stderr, status|
        return :orange
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A6',
  %w( colour lambda with too few parameters recorded in log ) do
    assert_stderr('wrong number of arguments (given 3, expected 2)',
      <<~RUBY
      lambda { |stdout, stderr|
        return :red
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A7',
  %w( colour lambda with too many parameters is recorded in log ) do
    assert_stderr('wrong number of arguments (given 3, expected 4)',
      <<~RUBY
      lambda { |stdout, stderr, status, extra|
        return :red
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  def assert_stderr(expected, rag_src)
    http_stub = HttpStub.new
    http_stub.stub({
      'stdout' => {
        'content' => rag_src
      }
    })
    @external = External.new({ 'http' => http_stub })
    with_captured_log {
      colour(PythonPytest::IMAGE_NAME, id, '', '', '0')
      assert_amber
    }
    assert @log.include?(expected)
  end

end
