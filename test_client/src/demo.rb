require_relative 'data/python_pytest'

class Demo

  def initialize(external)
    @external = external
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def call(_env)
    html = ''
    html += sha
    html += alive?
    html += ready?
    html += colour(PythonPytest::STDOUT_RED)
    html += colour(PythonPytest::STDOUT_AMBER)
    html += colour(PythonPytest::STDOUT_GREEN)
    # for faulty use an image that exists but does not have a
    # /usr/local/bin/red_amber_green.rb file
    # Using an image that does not exist will cause docker to
    # try and pull the image for several seconds.
    html += colour('faulty', 'cyberdojo/ragger:latest')
    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  rescue => error
    body = [ [error.message] + [error.backtrace] ]
    [ 200, { 'Content-Type' => 'text/html' }, body ]
  end

  private

  include Test::Data

  def sha
    duration,result = timed { ragger.sha }
    pre('sha', duration, 'LightGreen', result)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def alive?
    duration,result = timed { ragger.alive? }
    pre('alive?', duration, 'LightGreen', result)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def ready?
    duration,result = timed { ragger.ready? }
    pre('ready?', duration, 'LightGreen', result)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def colour(stdout, image_name = PythonPytest::IMAGE_NAME)
    args  = [ image_name, '729z65', stdout, '', 0 ]
    duration,result = timed { ragger.colour(*args) }
    pre('colour', duration, 'LightGreen', result)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def timed
    started = Time.now
    result = yield
    finished = Time.now
    duration = '%.4f' % (finished - started)
    [duration,result]
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def pre(name, duration, colour = 'white', result = nil)
    border = 'border: 1px solid black;'
    padding = 'padding: 5px;'
    margin = 'margin-left: 30px; margin-right: 30px;'
    background = "background: #{colour};"
    whitespace = "white-space: pre-wrap;"
    html = "<pre>/#{name}(#{duration}s)</pre>"
    unless result.nil?
      html += "<pre style='#{whitespace}#{margin}#{border}#{padding}#{background}'>" +
              "#{JSON.pretty_unparse(result)}" +
              '</pre>'
    end
    html
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def ragger
    @external.ragger
  end

end
