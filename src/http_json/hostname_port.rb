
module HostnamePort # mixin

  attr_reader :hostname, :port

  def hostname=(value)
    @hostname = value
  end

  def port=(value)
    @port = value
  end

  def base_url
    "http://#{@hostname}:#{@port}"
  end

end
