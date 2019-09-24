require_relative 'ragger_service'
require 'net/http'

class Externals

  def initialize(options = {})
    @http = options['http'] || Net::HTTP
    @ragger = RaggerService.new(self)
  end

  attr_reader :http, :ragger

end
