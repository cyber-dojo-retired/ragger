require 'net/http'

class HttpJsonRequestor

  def hostname=(value)
    @hostname = value
  end

  def port=(value)
    @port = value
  end

  def get(path, named_args)
    json_request(path, named_args) do |url|
      Net::HTTP::Get.new(url)
    end
  end

  def post(path, named_args)
    json_request(path, named_args) do |url|
      Net::HTTP::Post.new(url)
    end
  end

  private

  def json_request(path, named_args)
    uri = URI.parse("http://#{@hostname}:#{@port}/#{path}")
    req = yield uri
    req.content_type = 'application/json'
    req.body = named_args.to_json
    service = Net::HTTP.new(uri.host, uri.port)
    service.request(req)
  end

end
