require 'json'
require 'net/http'
require 'uri'

module HttpJson

  class RequestPacker

    def initialize(external, hostname, port)
      @external = external
      @hostname = hostname
      @port = port
    end

    def get(path, args)
      packed_request(path, args) do |url|
        Net::HTTP::Get.new(url)
      end
    end

    def post(path, args)
      packed_request(path, args) do |url|
        Net::HTTP::Post.new(url)
      end
    end

    private

    def packed_request(path, args)
      uri = URI.parse("http://#{@hostname}:#{@port}/#{path}")
      req = yield uri
      req.content_type = 'application/json'
      req.body = JSON.generate(args)
      http = @external.http.new(uri.host, uri.port)
      http.request(req)
    end

  end

end
