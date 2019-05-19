
class HttpStub

  def stub(response)
    @response = response
  end

  def post(_hostname, _port, method, _named_args)
    { method.to_s => @response }
  end

end
