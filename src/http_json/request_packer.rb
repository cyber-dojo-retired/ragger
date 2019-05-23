require 'json'
require 'net/http'
require 'uri'

module HttpJson

  class RequestPacker

    def initialize(external)
      @external = external
    end

    def get(hostname, port, path, args)
      packed(hostname, port, path, args) do |url|
        http_get(url)
      end
    end

    def post(hostname, port, path, args)
      packed(hostname, port, path, args) do |url|
        http_post(url)
      end
    end

    private

    def packed(hostname, port, path, args)
      uri = URI.parse("http://#{hostname}:#{port}/#{path}")
      req = yield uri
      req.content_type = 'application/json'
      req.body = JSON.generate(args)
      service = http(uri.host, uri.port)
      service.request(req)
    end

    def http_get(url)
      @external.http_get.new(url)
    end

    def http_post(url)
      @external.http_post.new(url)
    end

    def http(host, port)
      @external.http.new(host, port)
    end

  end

end
