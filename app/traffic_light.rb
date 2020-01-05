# frozen_string_literal: true

require_relative 'rag_lambda_cache'

class TrafficLight

  def initialize(external)
    @external = external
    @cache = RagLambdaCache.new(external)
  end

  def sha
    { 'sha' => ENV['SHA'] }
  end

  def alive?
    { 'alive?' => true }
  end

  def ready?
    { 'ready?' => runner.ready? }
  end

  def colour(image_name, id, stdout, stderr, status)
    diagnostic = {
      'image_name' => image_name,
      'id' => id,
      'stdout' => stdout,
      'stderr' => stderr,
      'status' => status
    }

    begin
      cached = @cache.get(image_name, id)
    rescue RagLambdaCreatorError => error
      diagnostic['info'] = error.info
      diagnostic['message'] = error.message
      diagnostic['source'] = error.source unless error.source.nil?
      result = {
        'diagnostic' => diagnostic,
        'colour' => 'faulty'
      }
      log << JSON.pretty_generate(result)
      return result
    end

    begin
      rag = cached[:fn].call(stdout, stderr, status)
    rescue => error
      diagnostic['info'] = 'calling the lambda raised an exception'
      diagnostic['message'] = error.message
      diagnostic['source'] = cached[:source]
      result = {
        'diagnostic' => diagnostic,
        'colour' => 'faulty'
      }
      log << JSON.pretty_generate(result)
      return result
    end

    rag = rag.to_s
    unless %w( red amber green ).include?(rag)
      diagnostic['info'] = "lambda returned '#{rag}' which is not 'red'|'amber'|'green'"
      diagnostic['source'] = cached[:source]
      result = {
        'diagnostic' => diagnostic,
        'colour' => 'faulty'
      }
      log << JSON.pretty_generate(result)
      return result
    end

    { 'colour' => rag.to_s }
  end

  #def new_image(image_name)
  #  @cache.new_image(image_name ,'111111')
  #end
  # The idea is that puller will be incorporated inside ragger
  # and when it pulls a new image, it will inform ragger, which
  # will run TrafficLight.new_image(...)
  # So '111111' will indicate a runner.run_cyber_dojo_sh() call
  # coming from ragger via a poke from puller.

  private

  def runner
    @external.runner
  end

  def log
    @external.log
  end

end
