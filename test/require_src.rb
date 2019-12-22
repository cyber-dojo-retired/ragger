
def require_src(required)
  require_relative "../#{required}"
end

=begin

Where does app-code live?
=========================
The app-code is in /app in the git repo.
This is added to the docker image in app/Dockerfile:

  COPY --chown=nobody:nogroup . /app

Aside: this sets the ownership of everything underneath /app
but it does _not_ set the ownership of /app itself.

Where does test-code live?
==========================
The test-code is in /test in the git-repo.
This is volume-mounted into a docker container in docker-compose.yml:

  ragger:
    read_only: true
    volumes: [ "./test:/app/test:ro" ]

Why is the dir/ structure inside the container different?
=========================================================
I would prefer to have app-code and test-code (inside the container) in
a 'non-parental' dir structure, to mirror the git-repo dir/ structure. Eg

  /app
  /test

However, I want full coverage of both app-code and test-code
and SimpleCov appears unable to work across two root dirs like this :-(
Although it does work if the dirs are not rooted, eg, /jj/app and /jj/test

It might be possible to add a sym-link to fake it, but the ln command
would not be possible inside the read-only file-system.

So, when looking at test-code in the git-repo you'd expect to access
the app-code like this:
   require_relative '../app/wibble'
But the access is like this:
   require_relative '../wibble'
The require_src method isolates this dependency in one place in case
it changes.

Shared files?
=============
test/client and test/server usefully share a number of files:
- check_test_results.rb
- coverage.rb
- hex_mini_test.rb
- require_src.rb
- run.sh

=end
