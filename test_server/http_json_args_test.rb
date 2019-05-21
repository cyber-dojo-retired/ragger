require_relative '../src/http_json_args'
require_relative 'data/ids'
require_relative 'data/image_names'
require_relative 'data/not_strings'
require_relative 'data/python_pytest'
require_relative 'test_base'
require 'json'

class HttpJsonArgsTest < TestBase

  def self.hex_prefix
    '348'
  end

  # - - - - - - - - - - - - - - - - -
  # not raising
  # - - - - - - - - - - - - - - - - -

  test 'AB3', 'for_sha' do
    assert_equal [], HttpJsonArgs.new('{}').for_sha
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB4', 'for_ready' do
    assert_equal [], HttpJsonArgs.new('{}').for_ready
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB5', 'for_colour' do
    args = HttpJsonArgs.new(JSON.generate(colour_payload)).for_colour
    assert_equal colour_payload.size, args.size
    assert_equal colour_payload[:image_name], args[0]
    assert_equal colour_payload[:id        ], args[1]
    assert_equal colour_payload[:stdout    ], args[2]
    assert_equal colour_payload[:stderr    ], args[3]
    assert_equal colour_payload[:status    ], args[4]
  end

  # - - - - - - - - - - - - - - - - -
  # raising
  # - - - - - - - - - - - - - - - - -

  test 'CB0',
  %w( raises when body is not JSON ) do
    expected = 'body is not JSON'
    assert_http_json_args_error(expected, 'sdfsdf')
    assert_http_json_args_error(expected, 'nil')
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB1',
  %w( raises when body is not JSON Hash ) do
    expected = 'body is not JSON Hash'
    assert_http_json_args_error(expected, 'null')
    assert_http_json_args_error(expected, '[]')
    assert_http_json_args_error(expected, 'true')
    assert_http_json_args_error(expected, '42')
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB2',
  %w( raises when color-image_name malformed ) do
    MALFORMED_IMAGE_NAMES.each do |malformed|
      args = colour_args('image_name', malformed)
      assert_http_json_args_error('image_name is malformed') do
        args.for_colour
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB3',
  %w( raises when colour-id is malformed ) do
    MALFORMED_IDS.each do |malformed|
      args = colour_args('id', malformed)
      assert_http_json_args_error('id is malformed') do
        args.for_colour
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB4',
  %w( raises when colour-stdout is malformed ) do
    NOT_STRINGS.each do |malformed|
      args = colour_args('stdout', malformed)
      assert_http_json_args_error('stdout is malformed') do
        args.for_colour
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB5',
  %w( raises when colour-stderr is malformed ) do
    NOT_STRINGS.each do |malformed|
      args = colour_args('stderr', malformed)
      assert_http_json_args_error('stderr is malformed') do
        args.for_colour
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB6',
  %w( raises when colour-status is malformed ) do
    NOT_STRINGS.each do |malformed|
      args = colour_args('status', malformed)
      assert_http_json_args_error('status is malformed') do
        args.for_colour
      end
    end
  end

  private # = = = = = = = = = = = = =

  include Test::Data

  def assert_http_json_args_error(expected, body = nil)
    error = assert_raises(HttpJsonRequestError) do
      if block_given?
        yield
      else
        HttpJsonArgs.new(body)
      end
    end
    assert_equal expected, error.message
  end

  # - - - - - - - - - - - - - - - - -

  def colour_payload
    {
      image_name: PythonPytest::IMAGE_NAME,
      id: id,
      stdout: PythonPytest::STDOUT_RED,
      stderr: '',
      status: '0'
    }
  end

  def colour_args(key, value)
    body = colour_payload
    body[key] = value
    HttpJsonArgs.new(JSON.generate(body))
  end

end
