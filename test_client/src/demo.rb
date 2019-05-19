require_relative 'ragger_service'

class Demo

  def call(env)
    inner_call(env)
  rescue => error
    [ 200, { 'Content-Type' => 'text/html' }, [ error.message ] ]
  end

  def inner_call(_env)
    @html = ''
    red
    amber
    green
    [ 200, { 'Content-Type' => 'text/html' }, [ @html ] ]
  end

  private

  def red
    change('hiker.c', hiker_c.sub('6 * 9', '6 * 9'))
    colour('Red')
  end

  def amber
    change('hiker.c', hiker_c.sub('6 * 9', 'syntax-error'))
    colour('Yellow')
  end

  def green
    change('hiker.c', hiker_c.sub('6 * 9', '6 * 7'))
    change('sandbox.sh', sandbox_sh.sub('make', 'make && echo x > small.file'))
    colour('Green')
  end

  def change(filename, content)
    @files[filename] = {
      'content' => content,
      'readonly' => false
    }
  end

  def colour(colour, max_seconds = 10)
    result = nil
    args  = [ id, @files ]
    duration = timed {
      result = ragger.colour_ruby(*args)
    }
    @html += pre('colour', duration, colour, result)
  end

  # - - - - - - - - - - - - - - - - - - - - -

  def ragger
    RaggerService.new
  end

  def timed
    started = Time.now
    yield
    finished = Time.now
    '%.2f' % (finished - started)
  end

  def starting_files
    {
      'hiker.c'       => content('hiker.c'),
      'hiker.h'       => content('hiker.h'),
      'hiker.tests.c' => content('hiker.tests.c'),
      'sandbox.sh'    => content('sandbox.sh'),
      'makefile'      => content('makefile')
    }
  end

  def hiker_c
    read('hiker.c')
  end

  def sandbox_sh
    read('sandbox.sh')
  end

  def content(filename)
    {
      'content' => read(filename),
      'readonly' => false
    }
  end

  def read(filename)
    home = ENV['RAGGER_HOME']
    IO.read("#{home}/test/start_files/gcc_assert/#{filename}")
  end

  def pre(name, duration, colour = 'white', result = nil)
    border = 'border: 1px solid black;'
    padding = 'padding: 5px;'
    margin = 'margin-left: 30px; margin-right: 30px;'
    background = "background: #{colour};"
    whitespace = "white-space: pre-wrap;"
    html = "<pre>/#{name}(#{duration}s)</pre>"
    unless result.nil?
      result.delete('files')
      html += "<pre style='#{whitespace}#{margin}#{border}#{padding}#{background}'>" +
              "#{JSON.pretty_unparse(result)}" +
              '</pre>'
    end
    html
  end

end
