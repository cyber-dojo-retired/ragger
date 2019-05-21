require_relative '../src/http_json_args'
require_relative 'data/ids'
require_relative 'data/image_names'
require_relative 'data/json'
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
    body = JSON.generate(colour_body)
    args = HttpJsonArgs.new(body).for_colour
    assert_equal colour_body.size, args.size
    assert_equal colour_body[:image_name], args[0]
    assert_equal colour_body[:id        ], args[1]
    assert_equal colour_body[:stdout    ], args[2]
    assert_equal colour_body[:stderr    ], args[3]
    assert_equal colour_body[:status    ], args[4]
  end

  # - - - - - - - - - - - - - - - - -
  # raising
  # - - - - - - - - - - - - - - - - -

  test 'CB0',
  %w( raises when body is not JSON ) do
    NOT_JSON.each do |arg|
      assert_http_json_args_error('body is not JSON', arg)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB1',
  %w( raises when body is not JSON Hash ) do
    JSON_NOT_HASH.each do |arg|
      assert_http_json_args_error('body is not JSON Hash', arg)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB2',
  %w( raises when color-image_name malformed ) do
    MALFORMED_IMAGE_NAMES.each do |image_name|
      args = colour_args('image_name', image_name)
      assert_http_json_args_error('image_name is malformed') do
        args.for_colour
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB3',
  %w( raises when colour-id is malformed ) do
    MALFORMED_IDS.each do |id|
      args = colour_args('id', id)
      assert_http_json_args_error('id is malformed') do
        args.for_colour
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB4',
  %w( raises when colour-stdout is malformed ) do
    NOT_STRINGS.each do |stdout|
      args = colour_args('stdout', stdout)
      assert_http_json_args_error('stdout is malformed') do
        args.for_colour
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB5',
  %w( raises when colour-stderr is malformed ) do
    NOT_STRINGS.each do |stderr|
      args = colour_args('stderr', stderr)
      assert_http_json_args_error('stderr is malformed') do
        args.for_colour
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB6',
  %w( raises when colour-status is malformed ) do
    NOT_STRINGS.each do |status|
      args = colour_args('status', status)
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

  def colour_body
    {
      image_name: PythonPytest::IMAGE_NAME,
      id: id,
      stdout: PythonPytest::STDOUT_RED,
      stderr: '',
      status: '0'
    }
  end

  def colour_args(key, value)
    body = colour_body
    body[key] = value
    HttpJsonArgs.new(JSON.generate(body))
  end

end
