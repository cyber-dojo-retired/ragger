require_relative 'base58'
require_relative 'docker/image_name'
require_relative 'http_json/error'
require 'json'

class HttpJsonArgs

  # Checks for arguments synactic correctness
  # Exception messages use the words 'body' and 'path'
  # to match RackDispatcher's exception keys.

  def initialize(body)
    @args = JSON.parse(body)
    unless @args.is_a?(Hash)
      fail HttpJson::Error, 'body is not JSON Hash'
    end
  rescue JSON::ParserError
    fail HttpJson::Error, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def get(path)
    case path
    when '/ready'
      ['ready?',[]]
    when '/sha'
      ['sha',[]]
    when '/colour'
      ['colour',[image_name, id, stdout, stderr, status]]
    else
      raise HttpJson::Error, 'unknown path'
    end
  end

  private

  def image_name
    name = __method__.to_s
    arg = @args[name]
    unless Docker::image_name?(arg)
      fail malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def id
    name = __method__.to_s
    arg = @args[name]
    unless well_formed_id?(arg)
      fail malformed(name)
    end
    arg
  end

  def well_formed_id?(arg)
    Base58.string?(arg) && arg.size === 6
  end

  # - - - - - - - - - - - - - - - -

  def stdout
    name = __method__.to_s
    arg = @args[name]
    unless arg.is_a?(String)
      fail malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def stderr
    name = __method__.to_s
    arg = @args[name]
    unless arg.is_a?(String)
      fail malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def status
    name = __method__.to_s
    arg = @args[name]
    unless arg.is_a?(String)
      fail malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def malformed(arg_name)
    HttpJson::Error.new("#{arg_name} is malformed")
  end

end
