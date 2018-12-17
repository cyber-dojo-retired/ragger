require_relative 'base58'
require_relative 'client_error'
require 'json'

# Checks for arguments synactic correctness

module WellFormedArgs

  def well_formed_args(s)
    @args = JSON.parse(s)
    if @args.nil? || !@args.is_a?(Hash)
      malformed('json')
    end
  rescue
    malformed('json')
  end

  # - - - - - - - - - - - - - - - -

  def id
    name = __method__.to_s
    arg = @args[name]
    unless Base58.string?(arg) && arg.size == 10
      malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def filename
    name = __method__.to_s
    arg = @args[name]
    unless arg.is_a?(String)
      malformed(name)
    end
    arg
  end

  # - - - - - - - - - - - - - - - -

  def content
    name = __method__.to_s
    arg = @args[name]
    unless arg.is_a?(String)
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

  def malformed(arg_name)
    raise ClientError, "#{arg_name}:malformed"
  end

end