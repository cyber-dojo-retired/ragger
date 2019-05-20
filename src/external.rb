require_relative 'http_json_requestor'
require_relative 'runner'
require_relative 'stdout_log'

class External

  def initialize(options = {})
    @http = options['http'] || HttpJsonRequestor.new
    @log = options['log'] || StdoutLog.new
    @runner = Runner.new(self)
  end

  attr_reader :http, :log, :runner

end
