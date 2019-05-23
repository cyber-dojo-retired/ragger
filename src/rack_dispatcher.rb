require_relative 'http_json_args'
require 'rack'
require 'json'

class RackDispatcher

  def initialize(traffic_light)
    @traffic_light = traffic_light
  end

  def call(env, request_class = Rack::Request)
    request = request_class.new(env)
    path = request.path_info[1..-1] # lose leading /
    body = request.body.read
    name,args = HttpJsonArgs.new(body).get(path)
    result = @traffic_light.public_send(name, *args)
    json_response(200, json_plain({ name => result }))
  rescue => error
    diagnostic = json_pretty({
      'exception' => {
        'path' => path,
        'body' => body,
        'class' => 'RaggerService',
        'message' => error.message,
        'backtrace' => error.backtrace
      }
    })
    $stderr.puts(diagnostic)
    $stderr.flush
    json_response(code(error), diagnostic)
  end

  private

  def json_plain(body)
    JSON.generate(body)
  end

  def json_pretty(body)
    JSON.pretty_generate(body)
  end

  def json_response(status, body)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  # - - - - - - - - - - - - - - - -

  CLIENT_ERROR_CODE = 400
  SERVER_ERROR_CODE = 500

  def code(error)
    if error.is_a?(HttpJsonRequestError)
      CLIENT_ERROR_CODE
    else
      SERVER_ERROR_CODE
    end
  end

end
