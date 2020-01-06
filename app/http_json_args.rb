# frozen_string_literal: true

require 'json'

class HttpJsonArgs

  class RequestError < RuntimeError
    def initialize(message)
      super
    end
  end

  def initialize(body)
    @json = json_parse(body)
    unless @json.is_a?(Hash)
      raise request_error('body is not JSON Hash')
    end
  rescue JSON::JSONError
    raise request_error('body is not JSON')
  end

  # - - - - - - - - - - - - - - - -

  def get(path)
    case path
    when '/sha'        then ['sha',[]]
    when '/alive'      then ['alive?',[]]
    when '/ready'      then ['ready?',[]]
    when '/colour'     then ['colour',[image_name, id, stdout, stderr, status]]
    #when '/new_image' then ['new_image', [image_name]]
    else
      raise request_error('unknown path')
    end
  end

  private

  def json_parse(body)
    if body === ''
      {}
    else
      JSON.parse!(body)
    end
  end

  def image_name
    arg('image_name')
  end

  def id
    arg('id')
  end

  def stdout
    arg('stdout')
  end

  def stderr
    arg('stderr')
  end

  def status
    arg('status')
  end

  # - - - - - - - - - - - - - - - -

  def arg(name)
    unless @json.has_key?(name)
      raise request_error("#{name} is missing")
    end
    @json[name]
  end

  # - - - - - - - - - - - - - - - -

  def request_error(text)
    # Exception messages use the words 'body' and 'path'
    # to match RackDispatcher's exception keys.
    RequestError.new(text)
  end

end
