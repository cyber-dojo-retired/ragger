require_relative '../src/http_json/response_unpacker'
require_relative 'http_stub'
require_relative 'test_base'

class HttpJsonResponseUnpackerTest < TestBase

  def self.hex_prefix
    'F90'
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE1',
  %w( URL must return a JSON Hash ) do
    json = [] # not a {} Hash
    assert_sha_request_with_http_json_stub_raises(json) { |error|
      assert_equal 'json is not a Hash', error.message
    }
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE2',
  %w( when URL returns a Hash with 'exception' key, its value is raised as JSON ) do
    json = { 'a' => 'a-msg', 'b' => 'b-msg' }
    assert_sha_request_with_http_json_stub_raises({ 'exception' => json }) { |error|
      assert_equal json, JSON.parse(error.message)
    }
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE3',
  %w( raise when URL returns a JSON Hash with the method key missing ) do
    json = {} # not { 'sha' => {...} }
    assert_sha_request_with_http_json_stub_raises(json) { |error|
      assert_equal "key for 'sha' is missing", error.message
    }
  end

  private

  def assert_sha_request_with_http_json_stub_raises(stub)
    external = External.new({ 'http' => HttpStub.new(stub) })
    target = HttpJson::ResponseUnpacker.new(external, 'runner', 4597)
    error = assert_raises { target.get('sha', {}) }
    yield error
  end

end
