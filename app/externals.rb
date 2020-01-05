# frozen_string_literal: true

require_relative 'services/runner'
require_relative 'stdout_log'
require 'net/http'

class Externals

  def http
    @http ||= Net::HTTP
  end

  def log
    @log ||= StdoutLog.new
  end

  def runner
    @runner ||= Runner.new(self)
  end

end
