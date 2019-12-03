require_relative '../src/rack_dispatcher'
require_relative 'data/json'
require_relative 'data/python_pytest'
require_relative 'http_stub'
require_relative 'rack_request_stub'
require_relative 'test_base'
require 'ostruct'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'D06'
  end

  # - - - - - - - - - - - - - - - - -
  # 200
  # - - - - - - - - - - - - - - - - -

  test 'AB1', %w(
  allow empty body instead of {} to facilitate
  kubernetes liveness/readiness http probes ) do
    rack_call('sha', '')
    sha = assert_200('sha')
    assert_sha(sha)
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB2', 'sha' do
    rack_call('sha', {}.to_json)
    sha = assert_200('sha')
    assert_sha(sha)
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB3', 'alive' do
    rack_call('alive', {}.to_json)
    ready = assert_200('alive?')
    assert ready
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB4', 'ready' do
    rack_call('ready', {}.to_json)
    ready = assert_200('ready?')
    assert ready
  end

  # - - - - - - - - - - - - - - - - -

  test 'AB5', 'colour red' do
    rack_call('colour', colour_payload.to_json)
    colour = assert_200('colour')
    assert_equal 'red', colour
  end

  # - - - - - - - - - - - - - - - - -
  # 400
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
  %w( missing image_name becomes 400 client error ) do
    payload = missing_args('image_name')
    assert_rack_call_error(400, 'image_name is missing', 'colour', payload.to_json)
  end

  test 'BB2',
  %w( missing id becomes 400 client error ) do
    payload = missing_args('id')
    assert_rack_call_error(400, 'id is missing', 'colour', payload.to_json)
  end

  test 'BB3',
  %w( missing stdout becomes 400 client error ) do
    payload = missing_args('stdout')
    assert_rack_call_error(400, 'stdout is missing', 'colour', payload.to_json)
  end

  test 'BB4',
  %w( missing stderr becomes 400 client error ) do
    payload = missing_args('stderr')
    assert_rack_call_error(400, 'stderr is missing', 'colour', payload.to_json)
  end

  test 'BB5',
  %w( missing status becomes 400 client error ) do
    payload = missing_args('status')
    assert_rack_call_error(400, 'status is missing', 'colour', payload.to_json)
  end

  # - - - - - - - - - - - - - - - - -
  # 500
  # - - - - - - - - - - - - - - - - -

  test 'BB7',
  %w( other errors become 500 server error ) do
    @externals = Externals.new({ 'http' => HttpStub })
    HttpStub.stub_request({})
    expected = "http response.body has no key for 'ready?':{}"
    assert_rack_call_error(500, expected, 'ready', {}.to_json)
    HttpStub.unstub_request
  end

  # - - - - - - - - - - - - - - - - -

  class HttpServiceDoesNotReturnJson
    def initialize(_hostname, _port)
    end
    def request(_req)
      not_json = 'XXX'
      OpenStruct.new(body:not_json)
    end
  end

  test 'D75', %w(
  when runner_service does not return json
  then it is mapped to colour=faulty
  and the details are logged to stdout
  ) do
    @externals = Externals.new({
      'http' => HttpServiceDoesNotReturnJson
    })
    rack_call('colour', colour_payload.to_json)
    assert_equal 200, @status
    assert_equal( {'colour':'faulty'}.to_json, @body)
    assert_equal '', @stderr
    assert @stdout.include?('red_amber_green lambda error mapped to :faulty')
    assert @stdout.include?('http response.body is not JSON:XXX')
  end

  # - - - - - - - - - - - - - - - - -

  class HttpServiceDoesNotReturnJsonHash
    def initialize(_hostname, _port)
    end
    def request(_req)
      json_but_not_hash = '[]'
      OpenStruct.new(body:json_but_not_hash)
    end
  end

  test 'D76', %w(
  when runner_service does not return json Hash
  then it is mapped to colour=faulty
  and the details are logged to stdout
  ) do
    @externals = Externals.new({
      'http' => HttpServiceDoesNotReturnJsonHash
    })
    rack_call('colour', colour_payload.to_json)
    assert_equal 200, @status
    assert_equal( {'colour':'faulty'}.to_json, @body)
    assert_equal '', @stderr
    assert @stdout.include?('red_amber_green lambda error mapped to :faulty')
    assert @stdout.include?('http response.body is not JSON Hash')
  end

  # - - - - - - - - - - - - - - - - -

  class HttpServiceReturnsJsonWithEmbeddedException
    def initialize(_hostname, _port)
    end
    def request(_req)
      embedded_exception = {'exception'=>{'message'=>'summat'}}
      OpenStruct.new(body:embedded_exception.to_json)
    end
  end

  test 'D77', %w(
  when runner_service return Json with embedded exception
  then it is mapped to colour=faulty
  and the details are logged to stdout
  ) do
    @externals = Externals.new({
      'http' => HttpServiceReturnsJsonWithEmbeddedException
    })
    rack_call('colour', colour_payload.to_json)
    assert_equal 200, @status
    assert_equal( {'colour':'faulty'}.to_json, @body)
    assert_equal '', @stderr
    assert @stdout.include?('red_amber_green lambda error mapped to :faulty')
    assert @stdout.include?({"message":"summat"}.to_json)
  end

  private # = = = = = = = = = = = = =

  include Test::Data

  def assert_200(name)
    assert_equal 200, @status
    assert_body_contains(name)
    refute_body_contains('exception')
    refute_body_contains('trace')
    assert_nothing_logged
    Oj.strict_load(@body)[name]
  end

  # - - - - - - - - - - - - - - - - -

  def assert_rack_call_error(status, expected, path_info, body)
    response = rack_call(path_info, body)
    assert_equal status, @status

    [@body, @stderr].each do |s|
      refute_nil s
      json = Oj.strict_load(s)
      ex = json['exception']
      refute_nil ex, 'there was no exception'
      assert_equal 'RaggerService', ex['class']
      assert_equal expected, ex['message']
      assert_equal 'Array', ex['backtrace'].class.name
    end
    response
  end

  # - - - - - - - - - - - - - - - - -

  def rack_call(path_info, body)
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
    response
  end

  # - - - - - - - - - - - - - - - - -

  def assert_body_contains(key)
    refute_nil @body
    json = Oj.strict_load(@body)
    assert json.has_key?(key)
  end

  def refute_body_contains(key)
    refute_nil @body
    json = Oj.strict_load(@body)
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
      'image_name' => PythonPytest::IMAGE_NAME,
      'id' => id,
      'stdout' => PythonPytest::STDOUT_RED,
      'stderr' => '',
      'status' => 0
    }
  end

  def missing_args(arg_name)
    args = colour_payload.dup
    args.delete(arg_name)
    args
  end

end
