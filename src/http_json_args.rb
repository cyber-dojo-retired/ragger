require_relative 'base58'
require_relative 'http_json_request_error'
require_relative 'well_formed_image_name'
require 'json'

# Checks for arguments synactic correctness

module HttpJsonArgs

  def http_json_args(body)
    @args = JSON.parse(body)
    unless @args.is_a?(Hash)
      raise HttpJsonRequestError, 'body is not JSON Hash'
    end
  rescue JSON::ParserError
    raise HttpJsonRequestError, 'body is not JSON'
  end

  # - - - - - - - - - - - - - - - -

  def image_name
    name = __method__.to_s
    arg = @args[name]
    unless well_formed_image_name?(arg)
      malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def id
    name = __method__.to_s
    arg = @args[name]
    unless well_formed_id?(arg)
      malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def stdout
    name = __method__.to_s
    arg = @args[name]
    unless arg.is_a?(String)
      malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def stderr
    name = __method__.to_s
    arg = @args[name]
    unless arg.is_a?(String)
      malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def status
    name = __method__.to_s
    arg = @args[name]
    unless arg.is_a?(String)
      malformed(name)
    end
    arg
  end

  private # = = = = = = = = = = = =

  include WellFormedImageName

  def well_formed_id?(arg)
    Base58.string?(arg) && arg.size === 6
  end

  def malformed(arg_name)
    raise HttpJsonRequestError, "#{arg_name} is malformed"
  end

end
