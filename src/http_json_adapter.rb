require 'net/http'
require 'json'

class HttpJsonAdapter

  def hostname=(value)
    @hostname = value
  end

  def port=(value)
    @port = value
  end

  def get(path, named_args)
    call(path, named_args) { |url| Net::HTTP::Get.new(url) }
  end

  def post(path, named_args)
    call(path, named_args) { |url| Net::HTTP::Post.new(url) }
  end

  private

  def call(path, named_args)
    uri = URI.parse("http://#{@hostname}:#{@port}/#{path}")
    req = yield uri
    req.content_type = 'application/json'
    req.body = named_args.to_json
    service = Net::HTTP.new(uri.host, uri.port)
    response = service.request(req)
    JSON.parse(response.body)
  end

end
