
def require_src(required)
  require_relative "../#{required}"
end

=begin
The app-code is in /app in the git repo.
This is added to the docker image using the app/Dockerfile command:
COPY --chown=nobody:nogroup . /app
Aside: this sets the ownership of everything underneath /app
but it does _not_ set the ownership of /app itself.

The test-code are in /test in the git-repo which is volume-mounted into,
and run from inside a docker container using docker-compose.yml:

  ragger:
    read_only: true
    volumes: [ "./test:/app/test:ro" ]

I would prefer to have code and tests (inside the container)
in a 'non-parental' dir structure, to mirror the git-repo structure. Eg
  /app
  /test

However, I want full coverage of both the source _and_ tests
and SimpleCov appears unable to work 'across' two dirs like this.
SimpleCov.root('/') does not work.

It might be possible to add sym-link to fake it, but the ln command
would not be possible inside the read-only file-system.

test/client and test/server usefully share a number of files:
- check_test_results.rb
- coverage.rb
- run.sh
=end
