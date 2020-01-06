# frozen_string_literal: true

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
    json_response_pass(200, result)
  rescue HttpJsonArgs::RequestError => error
    json_response_fail(400, path, body, error)
  rescue Exception => error
    json_response_fail(500, path, body, error)
  end

  private

  def json_response_pass(status, json)
    [ status,
      { 'Content-Type' => 'application/json' },
      [ JSON.fast_generate(json) ]
    ]
  end

  # - - - - - - - - - - - - - - - -

  def json_response_fail(status, path, body, caught_error)
    json = diagnostic(path, body, caught_error)
    body = JSON.pretty_generate(json)
    $stderr.puts(body)
    $stderr.flush
    [ status,
      { 'Content-Type' => 'application/json' },
      [ body ]
    ]
  end

  # - - - - - - - - - - - - - - - -

  def diagnostic(path, body, caught_error)
    { 'exception' => {
        'path' => path,
        'body' => body,
        'class' => 'RaggerService',
        'message' => caught_error.message,
        'backtrace' => caught_error.backtrace
      }
    }
  end

end
