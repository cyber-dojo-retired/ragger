require_relative 'http_json/requester'

class Runner

  def initialize(external)
    @http = HttpJson::Requester.new(external)
  end

  def ready?
    @http.get(HOSTNAME, PORT, 'ready?', {})
  end

  def run_cyber_dojo_sh(image_name, id, files, max_seconds)
    @http.post(HOSTNAME, PORT, 'run_cyber_dojo_sh', {
      image_name:image_name,
      id:id,
      files:files,
      max_seconds:max_seconds
    })
  end

  HOSTNAME = 'runner'
  PORT = 4597

end
