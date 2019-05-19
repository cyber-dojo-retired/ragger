
class HttpStub

  def stub(response)
    @response = response
  end

  def post(_hostname, _port, _method, _named_args)
    { method.to_s => @response }
  end

end
