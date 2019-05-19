
class HttpSpy

  attr_reader :spied

  def clear
    @spied = []
  end

  def stub(response)
    @response = response
  end

  def post(hostname, port, method, args)
    @spied << [ hostname, port, method.to_s, args ]
    { method.to_s => @response }
  end

end
