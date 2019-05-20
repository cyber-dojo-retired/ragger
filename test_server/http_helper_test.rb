require_relative 'http_stub'
require_relative '../src/service_error'
require_relative 'test_base'

class HttpHelperTest < TestBase

  def self.hex_prefix
    'F90'
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE1',
  %w( URL is assumed to return JSON Hash ) do
    json = [] # not a {} Hash
    assert_call_sha_with_http_json_stub_raises(json) { |error|
      assert_equal 'json is not a Hash', error.message
    }
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE2',
  %w( when URL returns a Hash with 'exception' key, its value is raised as JSON ) do
    json = { 'a' => 'a-msg', 'b' => 'b-msg' }
    assert_call_sha_with_http_json_stub_raises({ 'exception' => json }) { |error|
      assert_equal json, JSON.parse(error.message)
    }
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE3',
  %w( raise when URL returns a Hash with the method key missing ) do
    json = {} # not { 'sha' => {...} }
    assert_call_sha_with_http_json_stub_raises(json) { |error|
      assert_equal "key for 'sha' is missing", error.message
    }
  end

  private

  def assert_call_sha_with_http_json_stub_raises(stub)
    external = External.new({ 'http' => HttpStub.new(stub) })
    target = HttpJson.new(external, 'runner', '4597')
    error = assert_raises(ServiceError) {
      target.get('sha', no_args = {})
    }
    assert_equal 'http://runner:4597', error.service_name
    assert_equal 'sha', error.method_name
    yield error
  end

end
