require_relative 'data/python_pytest'

class Demo

  def initialize(external)
    @external = external
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def call(_env)
    @html = ''
    sha
    ready?
    colour('Red'   , PythonPytest::STDOUT_RED)
    colour('Yellow', PythonPytest::STDOUT_AMBER)
    colour('Green' , PythonPytest::STDOUT_GREEN)
    [ 200, { 'Content-Type' => 'text/html' }, [ @html ] ]
  rescue => error
    body = [ [error.message] + [error.backtrace] ]
    [ 200, { 'Content-Type' => 'text/html' }, body ]
  end

  private

  include Test::Data

  def sha
    duration = timed { @result = ragger.sha }
    @html += pre('sha', duration, 'Gray', @result)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def ready?
    duration = timed { @result = ragger.ready? }
    @html += pre('ready?', duration, 'Gray', @result)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def colour(css_colour, stdout)
    args  = [ PythonPytest::IMAGE_NAME, '729z65', stdout, '', 0 ]
    duration = timed { @result = ragger.colour(*args) }
    @html += pre('colour', duration, css_colour, @result)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def timed
    started = Time.now
    yield
    finished = Time.now
    '%.4f' % (finished - started)
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
