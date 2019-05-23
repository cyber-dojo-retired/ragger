require 'json'

module HttpJson

  class Requester

    def initialize(external)
      @external = external
    end

    def get(hostname, port, method_name, named_args)
      json_response(:get, hostname, port, method_name, named_args)
    end

    def post(hostname, port, method_name, named_args)
      json_response(:post, hostname, port, method_name, named_args)
    end

    private

    def json_response(gp, hostname, port, method_name, named_args)
      response = http.send(gp, hostname, port, method_name, named_args)
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
