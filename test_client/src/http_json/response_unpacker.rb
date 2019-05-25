require 'json'

module HttpJson

  class ResponseUnpacker

    def initialize(requester)
      @requester = requester
    end

    def get(path, args)
      response = @requester.get(path, args)
      unpacked(response.code, response.body, path.to_s)
    end

    private

    def unpacked(code, body, path)
      # code == 200,400,500
      json = JSON.parse(body)
      unless json.is_a?(Hash)
        # TODO: fail HttpJsonServiceError, '...'
        fail 'JSON is not a Hash'
      end
      if json.key?('exception')
        # TODO: fail HttpJsonServiceError, '...'
        fail JSON.pretty_generate(json['exception'])
      end
      unless json.key?(path)
        # TODO: fail HttpJsonServiceError, '...'
        fail "key for '#{path}' is missing"
      end
      json[path]
    rescue JSON::ParserError
      #  fail HttpJsonServiceError, '...'
      fail 'body is not JSON'
    end

  end

end