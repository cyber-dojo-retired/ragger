
class HttpStub

  def stub(response)
    @response = response
  end

  def post(hostname, port, method, args)
    { method.to_s => @response }
  end

end
