require_relative 'test_base'

class FeatureBadColourRbTest < TestBase

  def self.hex_prefix
    'F6D43'
  end

  # - - - - - - - - - - - - - - - - -

  test '5A3',
  %w( colour.rb syntax-error recorded in stderr ) do
    assert_stderr("undefined local variable or method `sdf'",
      <<~RUBY
      sdf
      RUBY
    )
  end

  test '5A4',
  %w( colour.rb explicit raise recorded in stderr ) do
    assert_stderr('wibble',
      <<~RUBY
      def colour(stdout, stderr, status)
        raise ArgumentError.new('wibble')
      end
      RUBY
    )
  end

  test '5A5',
  %w( colour.rb returning non red/amber/green recorded in stdout ) do
    assert_stdout('orange',
      <<~RUBY
      def colour(stdout, stderr, status)
        return :orange
      end
      RUBY
    )
  end

  test '5A6',
  %w( colour.rb with too few parameters recorded in stderr ) do
    assert_stderr('wrong number of arguments (given 3, expected 2)',
      <<~RUBY
      def colour(stdout, stderr)
        return :red
      end
      RUBY
    )
  end

  test '5A7',
  %w( colour.rb with too many parameters is recorded in stderr ) do
    assert_stderr('wrong number of arguments (given 3, expected 4)',
      <<~RUBY
      def colour(stdout, stderr, status, extra)
        return :red
      end
      RUBY
    )
  end

  # - - - - - - - - - - - - - - - - -

  def assert_stderr(expected, rag_src)
    with_captured_log {
      colour_rb(rag_src, '', '', '0')
    }
    assert stderr.include?(expected)
  end

  # - - - - - - - - - - - - - - - - -

  def assert_stdout(expected, rag_src)
    with_captured_log {
      colour_rb(rag_src, '', '', '0')
    }
    assert stdout.include?(expected)
  end

end
