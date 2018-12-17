require_relative '../src/rack_dispatcher'
require_relative 'rack_request_stub'
require_relative 'test_base'
require 'json'

class RackDispatcherTest < TestBase

  def self.hex_prefix
    'D06F7'
  end

  # - - - - - - - - - - - - - - - - -
  # colour: not raising
  # - - - - - - - - - - - - - - - - -

  test 'AB5', 'red' do
    path_info = 'colour'
    args = colour_args
    env = { path_info:path_info, body:args.to_json }
    rack_call(env)

    assert_200
    assert_body_contains(path_info)
    refute_body_contains('exception')
    refute_body_contains('trace')
    assert_nothing_logged
  end

  # - - - - - - - - - - - - - - - - -
  # colour: raising
  # - - - - - - - - - - - - - - - - -

  test 'BAF',
  %w( unknown method becomes exception ) do
    expected = 'json:malformed'
    assert_rack_call_exception(expected, nil,       '{}')
    assert_rack_call_exception(expected, [],        '{}')
    assert_rack_call_exception(expected, {},        '{}')
    assert_rack_call_exception(expected, true,      '{}')
    assert_rack_call_exception(expected, 42,        '{}')
    assert_rack_call_exception(expected, 'unknown', '{}')
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB0',
  %w( malformed json in http payload becomes exception ) do
    expected = 'json:malformed'
    method_name = 'colour'
    assert_rack_call_exception(expected, method_name, 'sdfsdf')
    assert_rack_call_exception(expected, method_name, 'nil')
    assert_rack_call_exception(expected, method_name, 'null')
    assert_rack_call_exception(expected, method_name, '[]')
    assert_rack_call_exception(expected, method_name, 'true')
    assert_rack_call_exception(expected, method_name, '42')
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB1',
  %w( malformed id becomes exception ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['id'] = malformed
      assert_rack_call_exception('id:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB6',
  %w( malformed filename becomes exception ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['filename'] = malformed
      assert_rack_call_exception('filename:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB2',
  %w( malformed content becomes exception ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['content'] = malformed
      assert_rack_call_exception('content:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB3',
  %w( malformed stdout becomes exception ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['stdout'] = malformed
      assert_rack_call_exception('stdout:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB4',
  %w( malformed stderr becomes exception ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['stderr'] = malformed
      assert_rack_call_exception('stderr:malformed', 'colour', payload.to_json)
    end
  end

  # - - - - - - - - - - - - - - - - -

  test 'BB5',
  %w( malformed status becomes exception ) do
    not_String.each do |malformed|
      payload = colour_args
      payload['status'] = malformed
      assert_rack_call_exception('status:malformed', 'colour', payload.to_json)
    end
  end

  private # = = = = = = = = = = = = =

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

  def assert_rack_call_exception(expected, path_info, body)
    env = { path_info:path_info, body:body }
    rack_call(env)
    assert_400
    assert_body_contains('exception', expected)
    assert_body_contains('trace')
    assert_log_contains('exception', expected)
    assert_log_contains('trace')
  end

  # - - - - - - - - - - - - - - - - -

  def rack_call(env, e = external)
    rack = RackDispatcher.new
    with_captured_log {
      @triple = rack.call(env, e, RackRequestStub)
      @code = @triple[0]
      @type = @triple[1]
      @body = @triple[2][0]
    }
    expected_type = { 'Content-Type' => 'application/json' }
    assert_equal expected_type, @type
  end

  # - - - - - - - - - - - - - - - - -

  def assert_200
    assert_equal 200, @code, @triple
  end

  def assert_400
    assert_equal 400, @code, @triple
  end

  # - - - - - - - - - - - - - - - - -

  def assert_body_contains(key, value = nil)
    refute_nil @body
    json = JSON.parse(@body)
    assert json.has_key?(key)
    unless value.nil?
      assert_equal value, json[key]
    end
  end

  def refute_body_contains(key)
    refute_nil @body
    json = JSON.parse(@body)
    refute json.has_key?(key)
  end

  # - - - - - - - - - - - - - - - - -

  def assert_log_contains(key, value = nil)
    refute_nil @log
    json = JSON.parse(@log)
    assert json.has_key?(key)
    unless value.nil?
      assert_equal value, json[key]
    end
  end

  def assert_nothing_logged
    assert_equal '', @log
  end

  # - - - - - - - - - - - - - - - - -

  def colour_args
    {
      id:id,
      filename:'colour.rb',
      content:python_pytest_colour_rb,
      stdout:python_pytest_stdout_red,
      stderr:'',
      status:'0'
    }
  end

end
