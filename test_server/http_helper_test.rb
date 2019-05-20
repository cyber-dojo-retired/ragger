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
    stubbed_http_json(not_hash = []) { |error|
      assert_equal 'json not a Hash', error.message
    }
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE2',
  %w( when URL returns a Hash with 'exception' key, its value is raised as JSON ) do
    json = { 'a' => 'a-msg', 'b' => 'b-msg' }
    stubbed_http_json({ 'exception' => json }) { |error|
      assert_equal json, JSON.parse(error.message)
    }
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE3',
  %w( raise when URL returns a Hash with the method key missing ) do
    stubbed_http_json({}) { |error|
      assert_equal 'method key missing', error.message
    }
  end

  private

  def stubbed_http_json(stub)
    external = External.new({ 'http' => HttpStub.new(stub) })
    target = HttpHelper.new(external, 'hostname', 'port')
    error = assert_raises(ServiceError) {
      target.get('sha', no_args = {})
    }
    assert_equal 'HttpHelper', error.service_name
    assert_equal 'sha', error.method_name
    yield error
  end

end
