require_relative 'runner'
require_relative 'stdout_log'
require 'net/http'

class External

  def initialize(options = {})
    @http_get  = options['http_get '] || Net::HTTP::Get
    @http_post = options['http_post'] || Net::HTTP::Post
    @http      = options['http'     ] || Net::HTTP
    @log       = options['log'      ] || StdoutLog.new
    @runner = Runner.new(self)
  end

  attr_reader :http_get, :http_post, :http
  attr_reader :log, :runner

end
