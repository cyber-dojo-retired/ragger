require 'json'
require 'ostruct'

class HttpStub

  def initialize(response)
    @response = OpenStruct.new(body:JSON.generate(response))
  end

  def get(_hostname, _port, path, _args)
    @response
  end

  def post(_hostname, _port, _path, _args)
    @response
  end

end
