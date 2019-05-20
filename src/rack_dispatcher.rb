require_relative 'http_json_request_error'
require_relative 'well_formed_args'
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

  private # = = = = = = = = = = = =

  include WellFormedArgs

  def name_args(name, body)
    well_formed_args(body)
    args = case name
      when /^ready$/  then []
      when /^sha/     then []
      when /^colour$/ then [image_name,id,stdout,stderr,status]
      else
        raise HttpJsonRequestError, 'json:malformed'
    end
    name += '?' if query?(name)
    [name, args]
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

  def query?(name)
    ['ready'].include?(name)
  end

  # - - - - - - - - - - - - - - - -

  def code(error)
    if error.is_a?(HttpJsonRequestError)
      400 # client_error
    else
      500 # server_error
    end
  end

end
