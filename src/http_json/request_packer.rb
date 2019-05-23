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
      packed(path, args) { |url| Net::HTTP::Get.new(url) }
    end

    def post(path, args)
      packed(path, args) { |url| Net::HTTP::Post.new(url) }
    end

    private

    def packed(path, args)
      uri = URI.parse("http://#{@hostname}:#{@port}/#{path}")
      req = yield uri
      req.content_type = 'application/json'
      req.body = JSON.generate(args)
      service = @external.http.new(uri.host, uri.port)
      service.request(req)
    end

  end

end
