require 'ostruct'

class HttpStub

  def initialize(_hostname, _port)
  end

  def self.stub_request(s)
    define_method(:request) do |_req|
      OpenStruct.new(:body => s)
    end
  end

  def self.unstub_request
    remove_method(:request)
  end

end
