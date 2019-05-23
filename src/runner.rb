require_relative 'http_json/request_packer'
require_relative 'http_json/response_unpacker'

class Runner

  def initialize(external)
    requester = HttpJson::RequestPacker.new(external, 'runner', 4597)
    @http = HttpJson::ResponseUnpacker.new(requester)
  end

  def ready?
    @http.get(__method__, {})
  end

  def run_cyber_dojo_sh(image_name, id, files, max_seconds)
    @http.post(__method__, {
      image_name:image_name,
      id:id,
      files:files,
      max_seconds:max_seconds
    })
  end

end
