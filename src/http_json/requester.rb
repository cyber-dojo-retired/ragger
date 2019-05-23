require 'json'

module HttpJson

  class Requester

    def initialize(external)
      @external = external
    end

    def get(hostname, port, path, args)
      json_response(:get, hostname, port, path, args)
    end

    def post(hostname, port, path, args)
      json_response(:post, hostname, port, path, args)
    end

    private

    def json_response(gp, hostname, port, path, args)
      response = http.send(gp, hostname, port, path, args)
      json = JSON.parse(response.body)
      unless json.is_a?(Hash)
        fail 'json is not a Hash'
      end
      if json.key?('exception')
        fail JSON.pretty_generate(json['exception'])
      end
      unless json.key?(path)
        fail "key for '#{path}' is missing"
      end
      json[path]
    end

    def http
      @external.http
    end

  end

end
