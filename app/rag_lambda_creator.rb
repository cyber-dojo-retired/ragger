# frozen_string_literal: true

require_relative 'empty'

class RagLambdaCreator

  def initialize(external)
    @external = external
  end

  def create(image_name, id = '111111', diagnostic={})
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
    { source:source, fn:fn }
  end

  private

  def runner
    @external.runner
  end

end
