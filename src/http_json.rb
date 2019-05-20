require_relative 'service_error'
require 'json'

class HttpJson

  def initialize(external, hostname, port)
    @external = external
    @hostname = hostname
    @port = port
  end

  def get(method_name, named_args)
    request('get', method_name, named_args)
  end

  def post(method_name, named_args)
    request('post', method_name, named_args)
  end

  private

  attr_reader :external, :hostname, :port

  def request(gp, method_name, named_args)
    json = http.public_send(gp, hostname, port, method_name, named_args)
    unless json.is_a?(Hash)
      message = 'json is not a Hash'
      fail http_json_error(method_name, message)
    end
    if json.key?('exception')
      message = JSON.pretty_generate(json['exception'])
      fail http_json_error(method_name, message)
    end
    unless json.key?(method_name)
      message = "key for '#{method_name}' is missing"
      fail http_json_error(method_name, message)
    end
    json[method_name]
  end

  def http_json_error(method_name, message)
    ServiceError.new(url, method_name, message)
  end

  def url
    "http://#{hostname}:#{port}"
  end

  def http
    external.http
  end

end
