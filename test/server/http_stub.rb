require 'ostruct'

class HttpStub

  def initialize(_hostname, _port)
  end

  def self.stub_request(json)
    define_method(:request) do |_req|
      OpenStruct.new(:body => JSON.generate(json))
    end
  end

  def self.unstub_request
    remove_method(:request)
  end

end
