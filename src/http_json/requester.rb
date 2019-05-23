require 'json'

module HttpJson

  class Requester

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
        fail 'json is not a Hash'
      end
      if json.key?('exception')
        fail JSON.pretty_generate(json['exception'])
      end
      unless json.key?(method_name)
        fail "key for '#{method_name}' is missing"
      end
      json[method_name]
    end

    def http
      @external.http
    end

  end

end
