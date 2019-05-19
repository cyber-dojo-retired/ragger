require_relative 'test_base'
require_relative '../src/service_error'

class HttpHelperTest < TestBase

  def self.hex_prefix
    'F90'
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE1',
  %w( URL is assumed to return JSON Hash ) do
    http_stub = Class.new do
      def get(_hostname, _port, _path, _named_args)
        [] # Array not Hash
      end
    end.new
    external = External.new({ 'http' => http_stub })
    target = HttpHelper.new(external, 'hostname', 'port')
    error = assert_raises(ServiceError) {
      target.get('sha', {})
    }
    assert_equal 'HttpHelper', error.service_name
    assert_equal 'sha', error.method_name
    assert_equal 'json not a Hash', error.message
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE2',
  %w( when URL returns a Hash with 'exception' key, its value is raised as JSON ) do
    http_stub = Class.new do
      def get(_hostname, _port, _path, _named_args)
        { 'exception' => { 'a' => 'a-msg', 'b' => 'b-msg' } }
      end
    end.new
    external = External.new({ 'http' => http_stub })
    target = HttpHelper.new(external, 'hostname', 'port')
    error = assert_raises(ServiceError) {
      target.get('sha', {})
    }
    assert_equal 'HttpHelper', error.service_name
    assert_equal 'sha', error.method_name
    expected = { 'a' => 'a-msg', 'b' => 'b-msg' }
    actual = JSON.parse(error.message)
    assert_equal expected, actual
  end

  # - - - - - - - - - - - - - - - - -

  test 'AE3',
  %w( when URL returns a Hash with the method key missing, it raises ) do
    http_stub = Class.new do
      def get(_hostname, _port, _path, _named_args)
        {}
      end
    end.new
    external = External.new({ 'http' => http_stub })
    target = HttpHelper.new(external, 'hostname', 'port')
    error = assert_raises(ServiceError) {
      target.get('sha', {})
    }
    assert_equal 'HttpHelper', error.service_name
    assert_equal 'sha', error.method_name
    assert_equal 'method key missing', error.message
  end

end
