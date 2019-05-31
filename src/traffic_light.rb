
class TrafficLight

  def initialize(external)
    @external = external
    @cache = {}
  end

  def sha
    ENV['SHA']
  end

  def ready?
    runner.ready?
  end

  def colour(image_name, id, stdout, stderr, status)
    @cache[image_name] ||= eval(get_rag_lambda_src(image_name, id))
    rag = @cache[image_name].call(stdout, stderr, status)
    unless [:red,:amber,:green].include?(rag)
      log << rag_message(rag.to_s)
      rag = :amber
    end
    rag.to_s
  rescue => error
    # See NOTES
    log << rag_message(error.message)
    'amber'
  end

  private

  def get_rag_lambda_src(image_name, id)
    files = { 'cyber-dojo.sh' => 'cat /usr/local/bin/red_amber_green.rb' }
    max_seconds = 1
    result = runner.run_cyber_dojo_sh(image_name, id, files, max_seconds)
    result['stdout']['content']
  end

  def rag_message(message)
    "red_amber_green lambda error mapped to :amber\n#{message}"
  end

  # - - - - - - - - - - - - - - - -

  def runner
    @external.runner
  end

  def log
    @external.log
  end

end
