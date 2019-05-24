require 'ostruct'

class HttpStub

  def initialize(_host,_port)
  end

  def self.stub_request(json)
    self.define_method(:request) do |_req|
      OpenStruct.new(:body => JSON.generate(json))
    end
  end

end
