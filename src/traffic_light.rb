
=begin
# NOTES
If the colour(image_name,...) is non-existent then runner
will raise an exception. Eg
{
  "path": "run_cyber_dojo_sh",
  "body": "{\"image_name\":\"does_not_exist\",\"id\":\"375D61\",\"files\":{\"cyber-dojo.sh\":{\"content\":\"cat /usr/local/bin/red_amber_green.rb\",\"truncated\":false}},\"max_seconds\":5}",
  "class": "RunnerStatelessService",
  "message": "{\n  \"command\": \"docker run --name=cyber_dojo_runner_375D61_600c70b7ebc6e7714b608b145d208911 --env CYBER_DOJO_IMAGE_NAME='does_not_exist' --env CYBER_DOJO_ID='375D61' --env CYBER_DOJO_SANDBOX='/sandbox'                            --tmpfs /sandbox:exec,size=50M,uid=41966,gid=51966                                  --tmpfs /tmp:exec,size=50M                                      --ulimit core=0 --ulimit fsize=16777216 --ulimit locks=128 --ulimit nofile=256 --ulimit nproc=128 --ulimit stack=8388608 --memory=512m --net=none --pids-limit=128 --security-opt=no-new-privileges --ulimit data=4294967296                                 --detach                  `# later docker execs`       --init                    `# pid-1 process`            --rm                      `# auto rm on exit`          --user=41966:51966      `# not root` does_not_exist bash -c 'sleep 5'\",\n  \"stdout\": \"\",\n  \"stderr\": \"Unable to find image 'does_not_exist:latest' locally\\ndocker: Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 10.0.2.3:53: read udp 10.0.2.15:35516->10.0.2.3:53: i/o timeout.\\nSee 'docker run --help'.\\n\",\n  \"status\": 125\n}",
  "backtrace": [...

So...
json = JSON.parse(error.message)
stdout = json['message']['stdout']  # ''
stdout = json['message']['stderr']  # "Unable to find image 'does_not_exist:latest' locally"
status = json['message']['status']  # '125'

The problem is that the rescue in colour() is catching more errors
than it should. I think it would help if I changed the API so that
colour() returned more than just eg 'red'.
It's tricky because there are several levels here...
Level 1: the [s,s,s] triple returned by the call to runner to get the lambda.
Level 2: the results of doing the eval() to get the lambda
Level 3: the results of doing the call() on the lambda
=end

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
    files = { 'cyber-dojo.sh' => intact('cat /usr/local/bin/red_amber_green.rb') }
    max_seconds = 1
    result = runner.run_cyber_dojo_sh(image_name, id, files, max_seconds)
    result['stdout']['content']
  end

  def rag_message(message)
    "red_amber_green lambda error mapped to :amber\n#{message}"
  end

  def intact(content)
    { 'content' => content, 'truncated' => false }
  end

  # - - - - - - - - - - - - - - - -

  def runner
    @external.runner
  end

  def log
    @external.log
  end

end
