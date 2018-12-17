
module HttpHelper # mix-in

  module_function

  def http_get_hash(method, args_hash)
    json = http.get(hostname, port, method, args_hash)
    result(json, method.to_s)
  end

  # - - - - - - - - - - - - - - - - - - -

  def result(json, name)
    fail error(name, 'bad json') unless json.class.name == 'Hash'
    exception = json['exception']
    fail error(name, exception)  unless exception.nil?
    fail error(name, 'no key')   unless json.key? name
    json[name]
  end

  def error(name, message)
    StandardError.new("#{self.class.name}:#{name}:#{message}")
  end

  def http
    @externals.http
  end

end
