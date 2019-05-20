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
    target = stubbed_http_helper(not_hash = [])
    error = assert_raises(ServiceError) {
      target.get('sha', no_args = {})
    }
    assert_equal 'HttpHelper', error.service_name
    assert_equal 'sha', error.method_name
    assert_equal 'json not a Hash', error.message
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE2',
  %w( when URL returns a Hash with 'exception' key, its value is raised as JSON ) do
    json = { 'a' => 'a-msg', 'b' => 'b-msg' }
    target = stubbed_http_helper({ 'exception' => json })
    error = assert_raises(ServiceError) {
      target.get('sha', {})
    }
    assert_equal 'HttpHelper', error.service_name
    assert_equal 'sha', error.method_name
    actual = JSON.parse(error.message)
    assert_equal json, actual
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE3',
  %w( raise when URL returns a Hash with the method key missing ) do
    target = stubbed_http_helper({})
    error = assert_raises(ServiceError) {
      target.get('sha', {})
    }
    assert_equal 'HttpHelper', error.service_name
    assert_equal 'sha', error.method_name
    assert_equal 'method key missing', error.message
  end

  private

  def stubbed_http_helper(stub)
    external = External.new({ 'http' => HttpStub.new(stub) })
    HttpHelper.new(external, 'hostname', 'port')
  end

end
