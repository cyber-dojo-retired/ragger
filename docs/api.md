# API
- - - -
# GET colour(image_name,id,stdout,stderr,status)
- parameters [(JSON-in)](#json-in)
  * **image_name:String** names a Docker image.
  * **id:String** for tracing, must be in [base58](https://github.com/cyber-dojo/ragger/blob/master/src/base58.rb).
  * **stdout:String** from a [runner](https://github.com/cyber-dojo/runner/blob/master/README.md#get-run_cyber_dojo_shimage_nameidfilesmax_seconds) call.
  * **stderr:String** from a [runner](https://github.com/cyber-dojo/runner/blob/master/README.md#get-run_cyber_dojo_shimage_nameidfilesmax_seconds) call.
  * **status:Integer** from a [runner](https://github.com/cyber-dojo/runner/blob/master/README.md#get-run_cyber_dojo_shimage_nameidfilesmax_seconds) call.
  * eg
  ```json
    {        "image_name": "cyberdojofoundation/gcc_assert",
                     "id": "15B9zD",
                 "stdout": "...",
                 "stderr": "...",
                 "status": 3,
    }
  ```
- returns [(JSON-out)](#json-out)
  * the [traffic-light colour](http://blog.cyber-dojo.org/2014/10/cyber-dojo-traffic-lights.html) "red", "amber", or "green", by passing the **stdout**, **stderr**, **status**
to a Ruby lambda, read from **image_name**, at /usr/local/bin/red_amber_green.rb.
- notes
  * if /usr/local/bin/red_amber_green.rb does not exist in **image_name**, the colour is "faulty".
  * if eval'ing its lambda raises an exception, the colour is "faulty".
  * if calling its lambda raises an exception, the colour is "faulty".
  * if calling its lambda returns anything other than :red, :amber, or :green, the colour is "faulty".
  * eg
    ```json
    { "colour": "green" }
    ```

- - - -
## GET ready?
Tests if the service is ready to handle requests.
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * **true** if the service is ready
  * **false** if the service is not ready
- notes
  * Used as a [Kubernetes](https://kubernetes.io/) readiness probe.
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?
  {"ready?":false}
  ```

- - - -
## GET alive?
Tests if the service is alive.  
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * **true**
- notes
  * Used as a [Kubernetes](https://kubernetes.io/) liveness probe.  
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/alive?
  {"alive?":true}
  ```

- - - -
## GET sha
The git commit sha used to create the Docker image.
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * the 40 character commit sha string.
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/sha
  {"sha":"41d7e6068ab75716e4c7b9262a3a44323b4d1448"}
  ```

- - - -
## JSON in
- All methods pass any arguments as a json hash in the http request body.
  * If there are no arguments you can use `''` (which is the default
    for `curl --data`) instead of `'{}'`.

- - - -
## JSON out      
- All methods return a json hash in the http response body.
  * If the method completes, a string key equals the method's name. eg
    ```bash
    $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?
    {"ready?":true}
    ```
  * If the method raises an exception, a string key equals `"exception"`, with
    a json-hash as its value. eg
    ```bash
    $ curl --silent -X POST http://${IP_ADDRESS}:${PORT}/colour | jq      
    {
      "exception": {
        "path": "/colour",
        "body": "",
        "class": "CreatorService",
        "message": "image_name is missing",
        "backtrace": [
          ...
          "/usr/bin/rackup:23:in `<main>'"
        ]
      }
    }
    ```
