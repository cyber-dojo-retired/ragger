require_relative '../src/data/python_pytest'
require_relative 'http_stub'
require_relative 'test_base'
require 'json'

class ApiTest < TestBase

  def self.hex_prefix
    '375'
  end

  include Test::Data

  test '762', 'sha' do
    assert_sha(sha)
  end

  test '763', 'ready?' do
    assert ready?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # colour - red/amber/green
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D1', 'red' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_RED, '', '0')
    assert_colour 'red'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D2', 'amber' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_AMBER, '', '0')
    assert_colour 'amber'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '3D3', 'green' do
    colour(PythonPytest::IMAGE_NAME, id, PythonPytest::STDOUT_GREEN, '', '0')
    assert_colour 'green'
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # colour - client-side errors
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F0', 'malformed image-name is client exception' do
    assert_client_exception('image_name is malformed') {
      image_name = nil
      colour(image_name, id, '', '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F1', 'malformed id is client exception' do
    assert_client_exception('id is malformed') {
      id = '1234567' # > 6
      colour(image_name, id, '', '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F2', 'malformed stdout is client exception' do
    assert_client_exception('stdout is malformed') {
      stdout = 999 # !String
      colour(image_name, id, stdout, '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F3', 'malformed stderr is client exception' do
    assert_client_exception('stderr is malformed') {
      stderr = 999 #  !String
      colour(image_name, id, '', stderr, '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F4', 'malformed status is client exception' do
    assert_client_exception('status is malformed') {
      status = 999 # !String
      colour(image_name, id, '', '', status)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
    test 'D61', 'wellformed-but non-existent image_name' do
    error = assert_raises(RuntimeError) {
      colour('does_not_exist', id, '', '', '0')
    }
    json = JSON.parse(error.message)
    assert_equal '/colour', json['path']
    assert_equal 'RaggerService', json['class']
    assert_equal expected_message, json['message']
  end
=end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # colour - server-side errors
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F5', 'http-json body is not JSON' do
    assert_server_exception(
      'body is not JSON',
      'xxxx'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F6', 'http-json body is not a Hash' do
    assert_server_exception(
      'JSON is not a Hash',
      JSON.generate([])
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F7', 'http-json body contains exception key' do
    json = { 'inner-key' => 'inner-value' }
    assert_server_exception(
      JSON.pretty_generate(json),
      JSON.generate({ 'exception' => json })
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F8', 'http-json body is missing method-name key' do
    assert_server_exception(
      "key for 'colour' is missing",
      JSON.generate({ 'xcolour' => [] })
    )
  end

  private

  def image_name
    PythonPytest::IMAGE_NAME
  end

  def assert_client_exception(expected_message)
    error = assert_raises(RuntimeError) { yield }
    json = JSON.parse(error.message)
    assert_equal '/colour', json['path']
    assert_equal 'RaggerService', json['class']
    assert_equal expected_message, json['message']
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  def assert_server_exception(expected_message, body)
    @external = External.new({ 'http' => HttpStub })
    HttpStub.stub_request(body)
    error = assert_raises(RuntimeError) {
      colour(image_name, id, '', '', '0')
    }
    assert_equal expected_message, error.message
  end

end
