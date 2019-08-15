
[![CircleCI](https://circleci.com/gh/cyber-dojo/ragger.svg?style=svg)](https://circleci.com/gh/cyber-dojo/ragger)

- The source for the [cyberdojo/ragger](https://hub.docker.com/r/cyberdojo/ragger/tags) Docker image.
- A docker-containerized micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- Returns the traffic-light colour, "red", "amber", or "green" for the
[stdout,stderr,status] produced by a
[runner.run_cyber_dojo_sh(...)](https://github.com/cyber-dojo/runner#get-run_cyber_dojo_shimage_nameidfilesmax_seconds) call.

- - - -
# API:
  * [GET colour(image_name,id,stdout,stderr,status)](#get-colourimage_nameidstdoutstderrstatus)  
  * [GET ready?()](#get-ready)
  * [GET alive?](#get-alive)  
  * [GET sha()](#get-sha)

- - - -
# JSON in, JSON out  
  * All methods receive a json hash.
    * The hash contains any method arguments as key-value pairs.
  * All methods return a json hash.
    * If the method completes, a key equals the method's name.
    * If the method raises an exception, a key equals "exception".

- - - -
# GET colour(image_name,id,stdout,stderr,status)
- returns the [traffic-light colour](http://blog.cyber-dojo.org/2014/10/cyber-dojo-traffic-lights.html) "red", "amber", or "green", by passing the **stdout**, **stderr**, **status**
to a Ruby lambda, read from **image_name**, at /usr/local/bin/red_amber_green.rb.
  * If /usr/local/bin/red_amber_green.rb does not exist in **image_name**, the colour is "faulty".
  * If eval'ing its lambda raises an exception, the colour is "faulty".
  * If calling its lambda raises an exception, the colour is "faulty".
  * If calling its lambda returns anything other than :red, :amber, or :green, the colour is "faulty".
  * eg
    ```json
    { "colour": "green" }
    ```
- parameters, eg
  * **image_name:String** names a Docker image.
  * **id:String** for tracing, must be in [base58](https://github.com/cyber-dojo/ragger/blob/master/src/base58.rb)
  * **stdout:String**
  * **stderr:String**
  * **status:Integer**
  * eg
  ```json
    {        "image_name": "cyberdojofoundation/gcc_assert",
                     "id": "15B9zD",
                 "stdout": "...",
                 "stderr": "...",
                 "status": 3,
    }
  ```

- - - -
# GET ready?
Useful as a readiness probe.
- returns
  * **true** if the service is ready
  ```json
  { "ready?": true }
  ```
  * **false** if the service is not ready
  ```json
  { "ready?": false }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
# GET alive?
Useful as a liveness probe.
- returns
  * **true**
  ```json
  { "alive?": true }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
## GET sha
The git commit sha used to create the Docker image.
- returns
  * The 40 character sha string.
  * eg
  ```json
  { "sha": "b28b3e13c0778fe409a50d23628f631f87920ce5" }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
# build the image and run the tests
- Builds the differ-server image and an example differ-client image.
- Brings up a differ-server container and a differ-client container.
- Runs the differ-server's tests from inside a differ-server container.
- Runs the differ-client's tests from inside the differ-client container.

```text
$ ./pipe_build_up_test.sh

Building ragger
Step 1/10 : FROM cyberdojo/rack-base
 ---> 53514ad27605
Step 2/10 : LABEL maintainer=jon@jaggersoft.com
 ---> Using cache
 ---> 94a6238b6740
Step 3/10 : WORKDIR /app
 ---> Using cache
 ---> f252d87f807d
Step 4/10 : COPY . .
 ---> Using cache
 ---> c322287d6cfa
Step 5/10 : RUN chown -R nobody:nogroup .
 ---> Using cache
 ---> a51513498236
Step 6/10 : ARG SHA
 ---> Using cache
 ---> ae5f826dee7f
Step 7/10 : ENV SHA=${SHA}
 ---> Using cache
 ---> fd297969adbb
Step 8/10 : EXPOSE 5537
 ---> Using cache
 ---> 42831378f96a
Step 9/10 : USER nobody
 ---> Using cache
 ---> 235ac55df13f
Step 10/10 : CMD [ "./up.sh" ]
 ---> Using cache
 ---> 5bce23fbcf86
Successfully built 5bce23fbcf86
Successfully tagged cyberdojo/ragger:latest

Building ragger-client
Step 1/5 : FROM  cyberdojo/rack-base
 ---> 53514ad27605
Step 2/5 : LABEL maintainer=jon@jaggersoft.com
 ---> Using cache
 ---> 94a6238b6740
Step 3/5 : COPY . /app
 ---> 5af4ea8a65ad
Step 4/5 : EXPOSE 5538
 ---> Running in ddd7656e9ebe
Removing intermediate container ddd7656e9ebe
 ---> 3c8d4eeb7286
Step 5/5 : CMD [ "./up.sh" ]
 ---> Running in 57ec10e1febf
Removing intermediate container 57ec10e1febf
 ---> c5f67b87bdaa
Successfully built c5f67b87bdaa
Successfully tagged cyberdojo/ragger-client:latest
Recreating test-ragger-runner-server ... done
Recreating test-ragger-server        ... done
Recreating test-ragger-client        ... done
Waiting until test-ragger-server is ready....OK
Checking test-ragger-server started cleanly...OK
Waiting until test-ragger-runner-server is ready.OK
Checking test-ragger-runner-server started cleanly...OK
Run options: --seed 31444

# Running:

........................................................

Finished in 3.011600s, 18.5948 runs/s, 369.5710 assertions/s.

56 runs, 1113 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/coverage. 770 / 770 LOC (100.0%) covered.
Coverage report copied to ragger/test_server/coverage/

                    tests |      56 !=     0 | true
                 failures |       0 ==     0 | true
                   errors |       0 ==     0 | true
                 warnings |       0 ==     0 | true
                    skips |       0 ==     0 | true
        duration(test)[s] |    3.01 <=     5 | true
         coverage(src)[%] |   100.0 ==   100 | true
        coverage(test)[%] |   100.0 ==   100 | true
   lines(test)/lines(src) |    2.28 >=   2.0 | true
     hits(src)/hits(test) |   13.01 >=  12.7 | true

Run options: --seed 29567

# Running:

...............

Finished in 1.484689s, 10.1031 runs/s, 49.8421 assertions/s.

15 runs, 74 assertions, 0 failures, 0 errors, 0 skips
Coverage report generated for MiniTest to /tmp/coverage. 214 / 214 LOC (100.0%) covered.
Coverage report copied to ragger/test_client/coverage/

                    tests |      15 !=     0 | true
                 failures |       0 ==     0 | true
                   errors |       0 ==     0 | true
                 warnings |       0 ==     0 | true
                    skips |       0 ==     0 | true
        duration(test)[s] |    1.48 <=     2 | true
         coverage(src)[%] |   100.0 ==   100 | true
        coverage(test)[%] |   100.0 ==   100 | true
   lines(test)/lines(src) |    2.15 >=     2 | true
     hits(src)/hits(test) |    1.10 >=     1 | true

------------------------------------------------------
All passed
Stopping test-ragger-client        ... done
Stopping test-ragger-server        ... done
Stopping test-ragger-runner-server ... done
Removing test-ragger-client        ... done
Removing test-ragger-server        ... done
Removing test-ragger-runner-server ... done
Removing network ragger_default
```

- - - -
# build the demo and run it
- Runs inside the ragger-client's container.
- Calls the ragger-server's methods and displays their json results and how long they took.
- If the ragger-client's IP address is 192.168.99.100 then put 192.168.99.100:5538 into your browser to see the output.

```bash
$ ./sh/run_demo.sh
```
![demo screenshot](test_client/src/demo_screenshot.png?raw=true "demo screenshot")

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
