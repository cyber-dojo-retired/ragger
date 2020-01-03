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
      cached = @cache.get(image_name, id, diagnostic)
    rescue => error
      diagnostic['exception'] = error.message
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
      diagnostic['message'] = 'calling the lambda raised an exception'
      diagnostic['exception'] = error.message
      result = {
        'diagnostic' => diagnostic,
        'colour' => 'faulty'
      }
      log << JSON.pretty_generate(result)
      return result
    end

    rag = rag.to_s
    unless %w( red amber green ).include?(rag)
      diagnostic['message'] = "lambda returned '#{rag}' which is not 'red'|'amber'|'green'"
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
  #  @cache.new_image(image_name)
  #end

  private

  def runner
    @external.runner
  end

  def log
    @external.log
  end

end
