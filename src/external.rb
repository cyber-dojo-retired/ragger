require_relative 'http_json_requestor'
require_relative 'stdout_log'
require_relative 'runner_service'

class External

  def initialize(options = {})
    @http = options['http'] || HttpJsonRequestor.new
    @log = options['log'] || StdoutLog.new
    @runner = RunnerService.new(self)
  end

  attr_reader :http, :log, :runner

end
