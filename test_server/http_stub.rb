
class HttpStub

  def initialize(response)
    @response = response
  end

  attr_reader :hostname, :port
  
  def hostname=(value)
    @hostname = value
  end

  def port=(value)
    @port = value
  end

  def get(_method, _named_args)
    @response
  end

  def post(_method, _named_args)
    @response
  end

end
