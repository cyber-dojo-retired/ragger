require_relative 'http_stub'
require_relative 'python_pytest'
require_relative 'test_base'

class ColourAmberOnErrorTest < TestBase

  def self.hex_prefix
    'F6D'
  end

  # - - - - - - - - - - - - - - - - -

  test '5A3',
  %w( syntax-error ) do
    assert_amber_error("undefined local variable or method `sdf'",
      <<~RUBY
      sdf
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A4',
  %w( explicit raise ) do
    assert_amber_error('wibble',
      <<~RUBY
      lambda { |stdout, stderr, status|
        raise ArgumentError.new('wibble')
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A5',
  %w( returning non red/amber/green ) do
    assert_amber_error('orange',
      <<~RUBY
      lambda { |stdout, stderr, status|
        return :orange
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A6',
  %w( too few parameters ) do
    assert_amber_error('wrong number of arguments (given 3, expected 2)',
      <<~RUBY
      lambda { |stdout, stderr|
        return :red
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A7',
  %w( too many parameters ) do
    assert_amber_error('wrong number of arguments (given 3, expected 4)',
      <<~RUBY
      lambda { |stdout, stderr, status, extra|
        return :red
      }
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  def assert_amber_error(expected, rag_src)
    stub = HttpStub.new({
      'run_cyber_dojo_sh' => {
        'stdout' => {
          'content' => rag_src
        }
      }
    })
    @external = External.new({ 'http' => stub })
    with_captured_log {
      colour(PythonPytest::IMAGE_NAME, id, '', '', '0')
      assert_amber
    }
    assert @log.include?(expected)
  end

end
