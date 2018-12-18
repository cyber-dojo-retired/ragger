require_relative 'client_error'
require_relative 'external'
require_relative 'ragger'
require_relative 'well_formed_args'
require 'rack'
require 'json'

class RackDispatcher

  def call(env, external = External.new, request = Rack::Request)
    name, args = name_args(request.new(env))
    ragger = Ragger.new(external)
    result = ragger.public_send(name, *args)
    json_triple(200, { name => result })
  rescue => error
    info = {
      'exception' => error.message,
      'trace' => error.backtrace,
    }
    external.log << to_json(info)
    json_triple(code_400_500(error), info)
  end

  private # = = = = = = = = = = = =

  include WellFormedArgs

  def name_args(request)
    name = request.path_info[1..-1] # lose leading /
    well_formed_args(request.body.read)
    args = case name
      when /^sha/     then []
      when /^colour$/ then [id,filename,content,stdout,stderr,status]
      else
        raise ClientError, 'json:malformed'
    end
    [name, args]
  end

  # - - - - - - - - - - - - - - - -

  def json_triple(code, body)
    [ code, { 'Content-Type' => 'application/json' }, [ to_json(body) ] ]
  end

  def to_json(o)
    JSON.pretty_generate(o)
  end

  def code_400_500(error)
    error.is_a?(ClientError) ? 400 : 500
  end

end
