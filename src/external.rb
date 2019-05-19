require_relative 'http'
require_relative 'log'
require_relative 'runner_service'

class External

  def runner
    RunnerService.new(self)
  end

  def http
    Http.new
  end

  def log
    Log.new
  end

end
