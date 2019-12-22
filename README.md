
[![CircleCI](https://circleci.com/gh/cyber-dojo/ragger.svg?style=svg)](https://circleci.com/gh/cyber-dojo/ragger)

- The source for the [cyberdojo/ragger](https://hub.docker.com/r/cyberdojo/ragger/tags) Docker image.
- A docker-containerized micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- An http service (rack based) to get the traffic-light colour, `"red"`, `"amber"`, or `"green"` for the [stdout,stderr,status] returned from a
[runner.run_cyber_dojo_sh(...)](https://github.com/cyber-dojo/runner/blob/master/README.md#get-run_cyber_dojo_shimage_nameidfilesmax_seconds) call.

- - - -
* [GET colour(image_name,id,stdout,stderr,status)](docs/api.md#get-colourimage_nameidstdoutstderrstatus)  
* [GET ready?](docs/api.md#get-ready)
* [GET alive?](docs/api.md#get-alive)  
* [GET sha](docs/api.md#get-sha)

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
