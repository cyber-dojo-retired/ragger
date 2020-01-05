# frozen_string_literal: true

require_relative 'empty'
require_relative 'rag_lambda_creator_error'

class RagLambdaCreator

  def initialize(external)
    @external = external
  end

  def create(image_name, id)
    files = { 'cyber-dojo.sh' => 'cat /usr/local/bin/red_amber_green.rb' }
    max_seconds = 1
    begin
      result = runner.run_cyber_dojo_sh(image_name, id, files, max_seconds)
    rescue Exception => error
      raise RagLambdaCreatorError.new(error.message, 'runner.run_cyber_dojo_sh() raised an exception')
    end
    begin
      source = result['stdout']['content']
      fn = Empty.binding.eval(source)
    rescue Exception => error
      raise RagLambdaCreatorError.new(error.message, 'eval(lambda) raised an exception', source)
    end
    { source:source, fn:fn }
  end

  private

  def runner
    @external.runner
  end

end
