require_relative 'test_base'
require_relative '../src/service_error'

class HttpHelperTest < TestBase

  def self.hex_prefix
    'F90'
  end

  # - - - - - - - - - - - - - - - - -

=begin
  test 'AE0',
  %w( URL is assumed to return json Hash ) do
    user = Class.new do
      def sha
        http_stub = Class.new do
          def get(_hostname, _port, _path, _named_args)
            [] # Array not Hash
          end
        end.new
        external = External.new({ 'http' => http_stub })
        target = HttpHelper.new(external, self, 'hostname', 'port')
        target.get
      end
    end.new
    error = assert_raises(ServiceError) {
      user.sha
    }
    assert_equal 'bad json', error.message
  end
=end

  # - - - - - - - - - - - - - - - - -

  test 'AE1',
  %w( simpler version ) do
    http_stub = Class.new do
      def get(_hostname, _port, _path, _named_args)
        [] # Array not Hash
      end
    end.new
    external = External.new({ 'http' => http_stub })
    target = HttpHelper.new(external, self, 'hostname', 'port')
    error = assert_raises(ServiceError) {
      target.get('sha', {})
    }
    assert_equal 'bad json', error.message
  end

end
