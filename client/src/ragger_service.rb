require_relative 'http_json_service'

class RaggerService

  def initialize
    @hostname = ENV['RAGGER_SERVICE_NAME']
    @port = ENV['RAGGER_SERVICE_PORT'].to_i
  end

  def colour(id, filename, content, stdout, stderr, status)
    args  = [id, filename, content, stdout, stderr, status]
    get(args, __method__)
  end

  private

  include HttpJsonService

  attr_reader :hostname, :port

end
