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

  test 'AB3', 'for sha' do
    target = HttpJsonArgs.new('{}')
    name,args = target.get('/sha')
    assert_equal 'sha', name
    assert_equal [], args
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB4', 'for ready' do
    target = HttpJsonArgs.new('{}')
    name,args = target.get('/ready')
    assert_equal 'ready?', name
    assert_equal [], args
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB5', 'for colour' do
    body = JSON.generate(colour_body)
    target = HttpJsonArgs.new(body)
    name,args = target.get('/colour')
    assert_equal 'colour', name
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

  test '21E',
  %w( raises when unknown path ) do
    target =  HttpJsonArgs.new('{}')
    assert_http_json_args_error('unknown path') do
      target.get('x')
    end
  end

  # - - - - - - - - - - - - - - - - -

  test '21F',
  %w( raises when known path with leading or trailing whitespace ) do
    space = ' '
    target =  HttpJsonArgs.new('{}')
    [ '/sha', '/ready', '/colour' ].each do |name|
      assert_http_json_args_error('unknown path') do
        target.get(space+name)
      end
      assert_http_json_args_error('unknown path') do
        target.get(name+space)
      end
    end
  end

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
        args.get('/colour')
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB3',
  %w( raises when colour-id is malformed ) do
    MALFORMED_IDS.each do |id|
      args = colour_args('id', id)
      assert_http_json_args_error('id is malformed') do
        args.get('/colour')
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB4',
  %w( raises when colour-stdout is malformed ) do
    NOT_STRINGS.each do |stdout|
      args = colour_args('stdout', stdout)
      assert_http_json_args_error('stdout is malformed') do
        args.get('/colour')
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB5',
  %w( raises when colour-stderr is malformed ) do
    NOT_STRINGS.each do |stderr|
      args = colour_args('stderr', stderr)
      assert_http_json_args_error('stderr is malformed') do
        args.get('/colour')
      end
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'CB6',
  %w( raises when colour-status is malformed ) do
    NOT_STRINGS.each do |status|
      args = colour_args('status', status)
      assert_http_json_args_error('status is malformed') do
        args.get('/colour')
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
