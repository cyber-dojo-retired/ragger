require_relative 'http_json_requester'

class Runner

  def initialize(external)
    @http = HttpJsonRequester.new(external, 'runner', 4597)
  end

  def ready?
    @http.get('ready?', {})
  end

  def run_cyber_dojo_sh(image_name, id, files, max_seconds)
    @http.post('run_cyber_dojo_sh', {
      image_name:image_name,
      id:id,
      files:files,
      max_seconds:max_seconds
    })
  end

end
