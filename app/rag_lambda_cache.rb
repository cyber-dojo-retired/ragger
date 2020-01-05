# frozen_string_literal: true

require_relative 'empty'
require 'concurrent'

class RagLambdaCache

  # This cache makes quite a difference to speed since
  # a no-op runner call takes typically at least 0.5 seconds

  def initialize(external)
    @external = external
    @cache = Concurrent::Map.new
  end

  def get(image_name, id, diagnostic)
    @cache[image_name] || new_image(image_name, id, diagnostic)
  end

  def new_image(image_name, id = '111111', diagnostic = {}) # [1]
    files = { 'cyber-dojo.sh' => 'cat /usr/local/bin/red_amber_green.rb' }
    max_seconds = 1

    begin
      result = runner.run_cyber_dojo_sh(image_name, id, files, max_seconds)
    rescue Exception => error
      diagnostic['message'] = 'runner.run_cyber_dojo_sh() raised an exception'
      diagnostic['exception'] = error.message
      raise StandardError.new
    end

    source = result['stdout']['content']
    diagnostic['lambda'] = source

    begin
      fn = Empty.binding.eval(source)
    rescue Exception => error
      diagnostic['message'] = 'eval(lambda) raised an exception'
      diagnostic['exception'] = error.message
      raise StandardError.new
    end

    @cache.compute(image_name) {
      { source:source, fn:fn }
    }
  end

  private

  def runner
    @external.runner
  end

end

# [1]
# The idea is that puller will be incorporated inside ragger
# and when it pulls a new image, it will inform ragger, which
# will run TrafficLight.new_image(...)
# So '111111' will indicate a runner.run_cyber_dojo_sh() call
# coming from ragger via a poke from puller.
