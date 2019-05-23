require_relative 'http_json/request_packer'
require_relative 'runner'
require_relative 'stdout_log'
require 'net/http'

class External

  def initialize(options = {})
    @http_get = Net::HTTP::Get
    @http_post = Net::HTTP::Post
    @http = Net::HTTP
    @http_tmp = options['http_tmp'] || HttpJson::RequestPacker.new(self)
    @log = options['log'] || StdoutLog.new
    @runner = Runner.new(self)
  end

  attr_reader :http_get, :http_post, :http
  attr_reader :http_tmp, :log, :runner

end
