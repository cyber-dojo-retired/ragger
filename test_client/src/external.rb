require_relative 'ragger_service'
require 'net/http'

class External

  def initialize
    @http = Net::HTTP
    @ragger = RaggerService.new(self)
  end

  attr_reader :http, :ragger

end
