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
    json_response(200, JSON.generate({ name => result }))
  rescue HttpJson::Error => error
    json_response(400, logged(JSON.pretty_generate(diagnostic(path, body, error))))
  rescue => error
    json_response(500, logged(JSON.pretty_generate(diagnostic(path, body, error))))
  end

  private

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

  def logged(message)
    $stderr.puts(message)
    $stderr.flush
    message
  end

  # - - - - - - - - - - - - - - - -

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

end
