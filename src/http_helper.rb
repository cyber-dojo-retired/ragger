require_relative 'service_error'
require 'json'

class HttpHelper

  def initialize(external, hostname, port)
    @external = external
    @hostname = hostname
    @port = port
  end

  def get(method, named_args)
    call('get', method, named_args)
  end

  def post(method, named_args)
    call('post', method, named_args)
  end

  private

  def call(gp, method, named_args)
    json = http.public_send(gp, @hostname, @port, method, named_args)
    fail_unless(method, 'json is not a Hash') { json.class.name == 'Hash' }
    exception = json['exception']
    fail_unless(method, pretty(exception)) { exception.nil? }
    fail_unless(method, "key for '#{method}' is missing") { json.key?(method) }
    json[method]
  end

  def fail_unless(name, message, &block)
    unless block.call
      fail ServiceError.new(self.class.name, name, message)
    end
  end

  def pretty(json)
    JSON.pretty_generate(json)
  end

  def http
    @external.http
  end

end
