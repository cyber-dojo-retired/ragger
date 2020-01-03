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
    rag = @cache.get(image_name, id)[:fn].call(stdout, stderr, status)
    unless [:red,:amber,:green].include?(rag)
      log << rag_message(rag.to_s)
      rag = :faulty
    end
    { 'colour' => rag.to_s }
  rescue => error
    log << rag_message(error.message)
    { 'colour' => 'faulty' }
  end

  #def new_image(image_name)
  #  @cache.new_image(image_name)
  #end

  private

  def rag_message(message)
    "red_amber_green lambda error mapped to :faulty\n#{message}\n"
  end

  # - - - - - - - - - - - - - - - -

  def runner
    @external.runner
  end

  def log
    @external.log
  end

end
