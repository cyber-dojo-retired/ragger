require_relative 'http'
require_relative 'log'
require_relative 'runner_service'

class External

  def initialize(options = {})
    @http = options['http'] || Http.new
    @log = Log.new
    @runner = RunnerService.new(self)
  end

  attr_reader :http, :log, :runner

end
