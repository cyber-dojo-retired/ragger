require_relative 'runner'
require_relative 'stdout_log'
require 'net/http'

class External

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @log  = options['log' ] || StdoutLog.new
    @runner = Runner.new(self)
  end

  attr_reader :http, :log, :runner

end
