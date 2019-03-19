# ragger

At the moment the runner also determines the traffic-light colour
from the sss triple (stdout,stderr,status).
I would like to strip that functionality from runner and put in
into this ragger service. RAG = Red/Amber/Green.

I envisage this starting as a straight "Sprout-Class" refactoring.
Viz the ragger service would hold a global rag_cache and it would
populate this from the rag-lambda source file inside the target image.
The extraction of the source of the rag-lambda file could be
delegated to the runner service! It would simply make a call...

class Ragger

  def initialize(external, cache)
    @external = external
    @cache = cache
  end

  def colour(image_name, id, stdout, stderr, status)
    rag_lambda = cache.rag_lambda(image_name) {
      get_rag_lambda(image_name, id)
    }
    rag = rag_lambda.call(stdout, stderr, status)
    unless [:red,:amber,:green].include?(rag)
      log << rag_message(rag.to_s)
      rag = :amber
    end
    rag.to_s
  rescue => error
    log << rag_message(error.message)
    'amber'
  end

  def get_rag_lambda(image_name, id)
    result = runner.run_cyber_dojo_sh(
        image_name,
        id,
        max_seconds = 5,
        { 'cyber-dojo.sh' => 'cat /usr/local/bin/red_amber_green.rb' }  
    )
    eval(result['stdout']['content'])
  end

  #...

end
