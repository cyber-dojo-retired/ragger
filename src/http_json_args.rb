require_relative 'base58'
require_relative 'http_json_request_error'
require_relative 'well_formed_image_name'
require 'json'

# Checks for arguments synactic correctness

class HttpJsonArgs

  def initialize(body)
    @args = JSON.parse(body)
    unless @args.is_a?(Hash)
      fail HttpJsonRequestError, 'body is not JSON Hash'
    end
  rescue JSON::ParserError
    fail HttpJsonRequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def for_colour
    [image_name, id, stdout, stderr, status]
  end

  private

  def image_name
    name = __method__.to_s
    arg = @args[name]
    unless well_formed_image_name?(arg)
      fail malformed(name)
    end
    arg
  end

  include WellFormedImageName

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
    HttpJsonRequestError.new("#{arg_name} is malformed")
  end

end
