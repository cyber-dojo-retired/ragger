require 'ostruct'

class HttpStub

  def initialize(_host,_port)
  end

  def self.request_returns(json)
    self.define_method(:request) do |_req|
      OpenStruct.new(:body => JSON.generate(json))
    end
  end

end
