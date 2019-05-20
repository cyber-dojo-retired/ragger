require_relative 'test_base'
require_relative 'python_pytest'

class ColourTest < TestBase

  def self.hex_prefix
    'C60'
  end

  # - - - - - - - - - - - - - - - - -

  test '6A1', 'red' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_RED, '', '0')
    assert red?
  end

  test '6A2', 'amber' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_AMBER, '', '0')
    assert amber?
  end

  test '6A3', 'green' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_GREEN, '', '0')
    assert green?
  end

  # - - - - - - - - - - - - - - - - -

  test '5A3',
  %w( amber for syntax-error ) do
    assert_amber_error("undefined local variable or method `sdf'",
      <<~RUBY
      sdf
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  test '5A4',
  %w( amber for explicit raise ) do
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
  %w( amber for non red/amber/green ) do
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
  %w( amber for too few parameters ) do
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
  %w( amber for too many parameters ) do
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
    spy = StdoutLogSpy.new
    @external = External.new({ 'http' => stub, 'log' => spy })
    colour(PythonPytest::IMAGE_NAME, id, '', '', '0')
    assert amber?
    assert spy.spied?(expected)
  end

  # - - - - - - - - - - - - - - - - -

  class StdoutLogSpy
    def <<(string)
      spied << string
    end
    def spied
      @spied ||= []
    end
    def spied?(string)
      spied[0].include?(string)
    end
  end

end
