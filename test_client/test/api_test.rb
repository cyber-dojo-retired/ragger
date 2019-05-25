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
      colour(nil, id, '', '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F1', 'malformed id is client exception' do
    assert_client_exception('id is malformed') {
      colour('gcc', 'X'+id, '', '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F2', 'malformed stdout is client exception' do
    assert_client_exception('stdout is malformed') {
      colour('gcc', id, 999, '', '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F3', 'malformed stderr is client exception' do
    assert_client_exception('stderr is malformed') {
      colour('gcc', id, '', 999, '0')
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F4', 'malformed status is client exception' do
    assert_client_exception('status is malformed') {
      colour('gcc', id, '', '', 999)
    }
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  # colour - server-side errors
  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F5', 'http body not json is server exception' do
    assert_server_exception(
      'body is not JSON',
      'xxxx'
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F6', 'http-json body is not a hash' do
    assert_server_exception(
      'JSON is not a Hash',
      JSON.generate([])
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F7', 'http-json body contains exception key' do
    assert_server_exception(
      '"inner-field"',
      JSON.generate({"exception" => "inner-field"})
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

  test '2F8', 'http-json body is missing method-name key' do
    assert_server_exception(
      "key for 'colour' is missing",
      JSON.generate({"xcolour" => []})
    )
  end

  private

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
      colour('gcc', id, '', '', '0')
    }
    assert_equal expected_message, error.message
  end

end
