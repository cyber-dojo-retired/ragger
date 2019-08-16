# frozen_string_literal: true

require 'net/http'
require 'oj'
require 'uri'

module HttpJson

  class RequestPacker

    def initialize(external, hostname, port)
      @http = external.http.new(hostname, port)
      @base_url = "http://#{hostname}:#{port}"
    end

    def get(path, args)
      packed(path, args) do |url|
        Net::HTTP::Get.new(url)
      end
    end

    private

    def packed(path, args)
      uri = URI.parse("#{@base_url}/#{path}")
      req = yield uri
      req.content_type = 'application/json'
      req.body = Oj.dump(args, STRICT_MODE)
      @http.request(req)
    end

    STRICT_MODE = { mode: :strict }

  end

end
