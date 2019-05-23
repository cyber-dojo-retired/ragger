require 'json'
require 'ostruct'

class HttpStub

  def initialize(response)
    @response = OpenStruct.new(body:JSON.generate(response))
  end

  def get(_hostname, _port, _method, _named_args)
    @response
  end

  def post(_hostname, _port, _method, _named_args)
    @response
  end

end
