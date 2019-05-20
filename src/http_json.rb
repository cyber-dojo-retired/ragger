require 'json'

class HttpJson

  def initialize(external, hostname, port)
    @external = external
    http.hostname = hostname
    http.port = port
  end

  def get(method_name, named_args)
    json_response(:get, method_name, named_args)
  end

  def post(method_name, named_args)
    json_response(:post, method_name, named_args)
  end

  private

  def json_response(gp, method_name, named_args)
    response = http.send(gp, method_name, named_args)
    json = JSON.parse(response.body)
    unless json.is_a?(Hash)
      message = 'json is not a Hash'
      fail StandardError, message
    end
    if json.key?('exception')
      message = JSON.pretty_generate(json['exception'])
      fail StandardError, message
    end
    unless json.key?(method_name)
      message = "key for '#{method_name}' is missing"
      fail StandardError, message
    end
    json[method_name]
  end

  def http
    @external.http
  end

end
