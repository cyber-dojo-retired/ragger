# frozen_string_literal: true

require_relative 'http_json/service_exception'

class RunnerException < HttpJson::ServiceException

  def initialize(message)
    super
  end

end
