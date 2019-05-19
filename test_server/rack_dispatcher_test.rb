require_relative '../src/rack_dispatcher'
require_relative 'malformed_data'
require_relative 'python_pytest'
require_relative 'rack_request_stub'
require_relative 'test_base'
require 'json'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'D06'
  end

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
  # colour: not raising
  # - - - - - - - - - - - - - - - - -

  test 'AB5', 'red' do
    rack_call({ path_info:'colour', body:colour_args.to_json })
    colour = assert_200('colour')
    assert_equal 'red', colour
  end

  # - - - - - - - - - - - - - - - - -
  # colour: raising
  # - - - - - - - - - - - - - - - - -

  test 'BAF',
  %w( unknown method becomes exception ) do
    expected = 'json:malformed'
    assert_rack_call_error(400, expected, nil,       '{}')
    assert_rack_call_error(400, expected, [],        '{}')
    assert_rack_call_error(400, expected, {},        '{}')
    assert_rack_call_error(400, expected, true,      '{}')
    assert_rack_call_error(400, expected, 42,        '{}')
    assert_rack_call_error(400, expected, 'unknown', '{}')
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB0',
  %w( malformed json in http payload becomes exception ) do
    expected = 'json:malformed'
    method_name = 'colour'
    assert_rack_call_error(400, expected, method_name, 'sdfsdf')
    assert_rack_call_error(400, expected, method_name, 'nil')
    assert_rack_call_error(400, expected, method_name, 'null')
    assert_rack_call_error(400, expected, method_name, '[]')
    assert_rack_call_error(400, expected, method_name, 'true')
    assert_rack_call_error(400, expected, method_name, '42')
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB1',
  %w( malformed image_name becomes exception ) do
    malformed_image_names.each do |malformed|
      payload = colour_args
      payload['image_name'] = malformed
      assert_rack_call_error(400, 'image_name:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB2',
  %w( malformed id becomes exception ) do
    malformed_ids.each do |malformed|
      payload = colour_args
      payload['id'] = malformed
      assert_rack_call_error(400, 'id:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB3',
  %w( malformed stdout becomes exception ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['stdout'] = malformed
      assert_rack_call_error(400, 'stdout:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB4',
  %w( malformed stderr becomes 400 error ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['stderr'] = malformed
      assert_rack_call_error(400, 'stderr:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB5',
  %w( malformed status becomes 400 error ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['status'] = malformed
      assert_rack_call_error(400, 'status:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB6',
  %w( server error becomes 500 error ) do
    http_stub = Class.new do
      def get(*args)
        fail ServiceError.new('HttpStubRaiser', 'ready?', 'no key')
      end
    end.new
    @external = External.new({ 'http' => http_stub })
    assert_rack_call_error(500, 'no key', 'ready', {}.to_json)
  end

  private # = = = = = = = = = = = = =

  include MalformedData

  def not_String
    [
      nil,
      [],
      0,
      42,
      { 'x' => [] },
    ]
  end

  # - - - - - - - - - - - - - - - - -

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

  def colour_args
    {
      image_name: PythonPytest::IMAGE_NAME,
      id: id,
      stdout: PythonPytest::STDOUT_RED,
      stderr: '',
      status: '0'
    }
  end

end
