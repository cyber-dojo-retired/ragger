
class HttpStub

  def initialize(response)
    @response = response
  end

  def get(_hostname, _port, _method, _named_args)
    @response
  end

  def post(_hostname, _port, _method, _named_args)
    @response
  end

end
