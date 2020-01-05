# frozen_string_literal: true

require_relative 'services/runner'
require_relative 'stdout_log'
require 'net/http'

class Externals

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @log  = StdoutLog.new
    @runner = Runner.new(self)
  end

  attr_reader :http, :log, :runner

end
