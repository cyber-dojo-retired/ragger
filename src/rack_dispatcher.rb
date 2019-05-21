require_relative 'http_json_args'
require_relative 'http_json_request_error'
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
    name, args = name_args(path, body)
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

  def name_args(path, body)
    args = HttpJsonArgs.new(body)
    checked_args = case path
      when /^ready$/  then args.for_ready
      when /^sha/     then args.for_sha
      when /^colour$/ then args.for_colour
      else
        # the word path in error.message matches RackDispatcher's
        # exception field 'path' => path
        raise HttpJsonRequestError, 'unknown path'
    end
    path += '?' if query?(path)
    [path, checked_args]
  end

  def query?(name)
    name === 'ready'
  end

  # - - - - - - - - - - - - - - - -

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
