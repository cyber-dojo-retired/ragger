require_relative 'http_json/service_exception'

class RaggerException < HttpJson::ServiceException

  def initialize(message)
    super
  end

end
