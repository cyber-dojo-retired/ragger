[![CircleCI](https://circleci.com/gh/cyber-dojo/ragger.svg?style=svg)](https://circleci.com/gh/cyber-dojo/ragger)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/ragger docker image

- A docker-containerized stateless micro-service for [cyber-dojo](http://cyber-dojo.org).
- Returns the traffic-light colour, "red", "amber", or "green" for a
[stdout,stderr,status] tuple produced by a
[runner.run_cyber_dojo_sh(...)](https://github.com/cyber-dojo/runner-stateless#post-run_cyber_dojo_shimage_nameidfilesmax_seconds) call.

API:
  * [GET colour(image_name,id,stdout,stderr,status)](#get-colourimage_nameidstdoutstderrstatus)
  * [GET ready?()](#get-ready)
  * [GET sha()](#get-sha)
  * All methods receive a json hash.
    * The hash contains any method arguments as key-value pairs.
  * All methods return a json hash.
    * If the method completes, a key equals the method's name.
    * If the method raises an exception, a key equals "exception".

- - - -

# GET colour(image_name,id,stdout,stderr,status)
- returns the [traffic-light colour](http://blog.cyber-dojo.org/2014/10/cyber-dojo-traffic-lights.html) "red", "amber", or "green", by passing the **stdout**, **stderr**, **status**
strings to a Ruby lambda, read from **image_name**, at /usr/local/bin/red_amber_green.rb.
  * If this file does not exist in **image_name**, the colour is "amber".
  * If eval'ing the lambda raises an exception, the colour is "amber".
  * If calling the lambda raises an exception, the colour is "amber".
  * If calling the lambda returns anything other than :red, :amber, or :green, the colour is "amber".
  * eg
    ```
    $ docker run --rm cyberdojofoundation/gcc_assert bash -c 'cat /usr/local/bin/red_amber_green.rb'

    lambda { |stdout, stderr, status|
      output = stdout + stderr
      return :red   if /(.*)Assertion(.*)failed./.match(output)
      return :green if /(All|\d+) tests passed/.match(output)
      return :amber
    }
    ```

- parameters, eg
```
  {        "image_name": "cyberdojofoundation/gcc_assert",
                   "id": "15B9zD",
               "stdout": "...",
               "stderr": "...",
               "status": "3",
  }
```

- - - -

## GET ready?
- returns true if the service is ready, otherwise false, eg
  ```
  { "ready?": true }
  { "ready?": false }
  ```
- parameters, none
  ```
  {}
  ```

- - - -

## GET sha
- returns the git commit sha used to create the docker image, eg
  ```
  { "sha": "b28b3e13c0778fe409a50d23628f631f87920ce5" }
  ```
- parameters, none
  ```
  {}
  ```

- - - -
- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to the http://cyber-dojo.org site](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
