require_relative 'http'
require_relative 'log'

class External

  def http
    Http.new
  end

  def log
    Log.new
  end

end
