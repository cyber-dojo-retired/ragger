require_relative 'http_json_args'
require 'rack'
require 'json'

class RackDispatcher

  def initialize(traffic_light)
    @traffic_light = traffic_light
  end

  def call(env, request_class = Rack::Request)
    request = request_class.new(env)
    path = request.path_info
    body = request.body.read
    name,args = HttpJsonArgs.new(body).get(path)
    result = @traffic_light.public_send(name, *args)
    json_response(200, { name => result })
  rescue HttpJson::Error => error
    json_response(400, diagnostic(path, body, error))
  rescue => error
    json_response(500, diagnostic(path, body, error))
  end

  private

  def json_response(status, json)
    if status == 200
      body = JSON.generate(json)
    else
      body = JSON.pretty_generate(json)
      $stderr.puts(body)
      $stderr.flush
    end
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  # - - - - - - - - - - - - - - - -

  def diagnostic(path, body, error)
    { 'exception' => {
        'path' => path,
        'body' => body,
        'class' => 'RaggerService',
        'message' => error.message,
        'backtrace' => error.backtrace
      }
    }
  end

end
