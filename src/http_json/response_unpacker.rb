require 'json'

module HttpJson

  class ResponseUnpacker

    def initialize(external, hostname, port)
      @external = external
      @hostname = hostname
      @port = port
    end

    def get(path, args)
      json_response(:get, path.to_s, args)
    end

    def post(path, args)
      json_response(:post, path.to_s, args)
    end

    private

    def json_response(gp, path, args)
      response = http.send(gp, @hostname, @port, path, args)
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
