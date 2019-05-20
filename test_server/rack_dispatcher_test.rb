require_relative '../src/http_hostname_port'
require_relative '../src/rack_dispatcher'
require_relative 'image_name_data'
require_relative 'python_pytest'
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
    rack_call({ path_info:'sha', body:{}.to_json })
    sha = assert_200('sha')
    assert_sha(sha)
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB4', 'ready' do
    rack_call({ path_info:'ready', body:{}.to_json })
    ready = assert_200('ready?')
    assert ready
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB5', 'red' do
    rack_call({ path_info:'colour', body:colour_payload.to_json })
    colour = assert_200('colour')
    assert_equal 'red', colour
  end

  # - - - - - - - - - - - - - - - - -
  # raising
  # - - - - - - - - - - - - - - - - -

  test 'BAF',
  %w( unknown method-path becomes 400 client error ) do
    assert_rack_call_error(400, 'unknown path', nil, '{}')
  end

  # - - - - - - - - - - - - - - - - -

  test 'B00',
  %w( body not json becomes 400 client error ) do
    assert_rack_call_error(400,'body is not JSON', 'colour', 'sdfsdf')
  end

  test 'B01',
  %w( body not json Hash becomes 400 client error ) do
    assert_rack_call_error(400, 'body is not JSON Hash', 'colour', 'null')
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB1',
  %w( malformed image_name becomes 400 client error ) do
    payload = colour_args('image_name', ImageNameData::malformed[0])
    assert_rack_call_error(400, 'image_name is malformed', 'colour', payload.to_json)
  end

  test 'BB2',
  %w( malformed id becomes 400 client error ) do
    payload = colour_args('id', malformed_ids[0])
    assert_rack_call_error(400, 'id is malformed', 'colour', payload.to_json)
  end

  test 'BB3',
  %w( malformed stdout becomes 400 client error ) do
    payload = colour_args('stdout', non_strings[0])
    assert_rack_call_error(400, 'stdout is malformed', 'colour', payload.to_json)
  end

  test 'BB4',
  %w( malformed stderr becomes 400 client error ) do
    payload = colour_args('stderr', non_strings[0])
    assert_rack_call_error(400, 'stderr is malformed', 'colour', payload.to_json)
  end

  test 'BB5',
  %w( malformed status becomes 400 client error ) do
    payload = colour_args('status', non_strings[0])
    assert_rack_call_error(400, 'status is malformed', 'colour', payload.to_json)
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB6',
  %w( other errors become 500 server error ) do
    http_stub = Class.new do
      include HttpHostnamePort
      def get(_name, _args)
        fail StandardError, 'no key'
      end
    end.new
    @external = External.new({ 'http' => http_stub })
    assert_rack_call_error(500, 'no key', 'ready', {}.to_json)
  end

  private # = = = = = = = = = = = = =

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
    env = { path_info:path_info, body:body }
    rack_call(env)
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

  def rack_call(env, e = external)
    traffic_light = TrafficLight.new(e)
    rack = RackDispatcher.new(traffic_light)
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
      status: '0'
    }
  end

  def colour_args(arg_name, value)
    args = colour_payload.dup
    args[arg_name] = value
    args
  end

  # - - - - - - - - - - - - - - - - -

  def malformed_ids
    [
      nil,          # not String
      Object.new,   # not String
      [],           # not String
      '',           # not 6 chars
      '12345',      # not 6 chars
      '1234567',    # not 6 chars
    ]
  end

  # - - - - - - - - - - - - - - - - -

  def non_strings
    [
      nil,
      [],
      0,
      42,
      { 'x' => [] },
    ]
  end

end
