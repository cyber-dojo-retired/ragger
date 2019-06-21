require_relative '../src/rack_dispatcher'
require_relative 'data/ids'
require_relative 'data/image_names'
require_relative 'data/json'
require_relative 'data/not_integers'
require_relative 'data/not_strings'
require_relative 'data/python_pytest'
require_relative 'http_stub'
require_relative 'rack_request_stub'
require_relative 'test_base'
require 'json'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'D06'
  end

  # - - - - - - - - - - - - - - - - -
  # not raising
  # - - - - - - - - - - - - - - - - -

  test 'AB3', 'sha' do
    rack_call('sha', {}.to_json)
    sha = assert_200('sha')
    assert_sha(sha)
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB4', 'ready' do
    rack_call('ready', {}.to_json)
    ready = assert_200('ready?')
    assert ready
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB5', 'red' do
    rack_call('colour', colour_payload.to_json)
    colour = assert_200('colour')
    assert_equal 'red', colour
  end

  # - - - - - - - - - - - - - - - - -
  # raising
  # - - - - - - - - - - - - - - - - -

  test 'B00',
  %w( body not json becomes 400 client error ) do
    NOT_JSON.each do |arg|
      assert_rack_call_error(400,'body is not JSON', 'colour', arg)
    end
  end

  test 'B01',
  %w( body not json Hash becomes 400 client error ) do
    JSON_NOT_HASH.each do |arg|
      assert_rack_call_error(400, 'body is not JSON Hash', 'colour', arg)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'B02',
  %w( unknown method-path becomes 400 client error ) do
    assert_rack_call_error(400, 'unknown path', nil, '{}')
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB1',
  %w( malformed image_name becomes 400 client error ) do
    MALFORMED_IMAGE_NAMES.each do |image_name|
      payload = colour_args('image_name', image_name)
      assert_rack_call_error(400, 'image_name is malformed', 'colour', payload.to_json)
    end
  end

  test 'BB2',
  %w( malformed id becomes 400 client error ) do
    MALFORMED_IDS.each do |id|
      payload = colour_args('id', id)
      assert_rack_call_error(400, 'id is malformed', 'colour', payload.to_json)
    end
  end

  test 'BB3',
  %w( malformed stdout becomes 400 client error ) do
    NOT_STRINGS.each do |stdout|
      payload = colour_args('stdout', stdout)
      assert_rack_call_error(400, 'stdout is malformed', 'colour', payload.to_json)
    end
  end

  test 'BB4',
  %w( malformed stderr becomes 400 client error ) do
    NOT_STRINGS.each do |stderr|
      payload = colour_args('stderr', stderr)
      assert_rack_call_error(400, 'stderr is malformed', 'colour', payload.to_json)
    end
  end

  test 'BB5',
  %w( malformed status becomes 400 client error ) do
    NOT_INTEGERS.each do |status|
      payload = colour_args('status', status)
      assert_rack_call_error(400, 'status is malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB6',
  %w( other errors become 500 server error ) do
    @external = External.new({ 'http' => HttpStub })
    HttpStub.stub_request({})
    expected = "key for 'ready?' is missing"
    assert_rack_call_error(500, expected, 'ready', {}.to_json)
    HttpStub.unstub_request    
  end

  private # = = = = = = = = = = = = =

  include Test::Data

  def assert_200(name)
    assert_equal 200, @status
    assert_body_contains(name)
    refute_body_contains('exception')
    refute_body_contains('trace')
    assert_nothing_logged
    JSON.parse(@body)[name]
  end

  # - - - - - - - - - - - - - - - - -

  def assert_rack_call_error(status, expected, path_info, body)
    rack_call(path_info, body)
    assert_equal @status, status

    [@body, @stderr].each do |s|
      refute_nil s
      json = JSON.parse(s)
      ex = json['exception']
      refute_nil ex
      assert_equal 'RaggerService', ex['class']
      assert_equal expected, ex['message']
      assert_equal 'Array', ex['backtrace'].class.name
    end
  end

  # - - - - - - - - - - - - - - - - -

  def rack_call(path_info, body)
    traffic_light = TrafficLight.new(external)
    rack = RackDispatcher.new(traffic_light)
    env = { path_info:path_info, body:body }
    response = with_captured_stdout_stderr {
      rack.call(env, RackRequestStub)
    }
    @status = response[0]
    @type = response[1]
    @body = response[2][0]

    expected_type = { 'Content-Type' => 'application/json' }
    assert_equal expected_type, @type
  end

  # - - - - - - - - - - - - - - - - -

  def with_captured_stdout_stderr
    begin
      old_stdout = $stdout
      old_stderr = $stderr
      $stdout = StringIO.new('', 'w')
      $stderr = StringIO.new('', 'w')
      response = yield
      @stderr = $stderr.string
      @stdout = $stdout.string
      response
    ensure
      $stderr = old_stderr
      $stdout = old_stdout
    end
  end

  # - - - - - - - - - - - - - - - - -

  def assert_body_contains(key)
    refute_nil @body
    json = JSON.parse(@body)
    assert json.has_key?(key)
  end

  def refute_body_contains(key)
    refute_nil @body
    json = JSON.parse(@body)
    refute json.has_key?(key)
  end

  # - - - - - - - - - - - - - - - - -

  def assert_nothing_logged
    assert_equal '', @stdout
    assert_equal '', @stderr
  end

  # - - - - - - - - - - - - - - - - -

  def colour_payload
    {
      image_name: PythonPytest::IMAGE_NAME,
      id: id,
      stdout: PythonPytest::STDOUT_RED,
      stderr: '',
      status: 0
    }
  end

  def colour_args(arg_name, value)
    args = colour_payload.dup
    args[arg_name] = value
    args
  end

end
