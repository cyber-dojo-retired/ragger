require_relative 'http_json_service'

class RaggerService

  def initialize
    @hostname = 'ragger'
    @port = 5537
  end

  def colour(id, filename, content, stdout, stderr, status)
    args  = [id, filename, content, stdout, stderr, status]
    get(args, __method__)
  end

  private

  include HttpJsonService

  attr_reader :hostname, :port

end
