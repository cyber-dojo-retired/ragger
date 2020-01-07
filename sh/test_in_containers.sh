#!/bin/bash -Ee

readonly root_dir="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly my_name=ragger

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  local -r coverage_root=/tmp/coverage
  local -r user="${1}" # eg nobody
  local -r type="${2}" # eg client|server
  local -r test_log=test.log
  local -r test_dir="${root_dir}/test/${type}"      # eg ..../test/server
  local -r container_name="test-${my_name}-${type}" # eg test-ragger-server

  echo '=================================='
  echo "Running ${type} tests"
  echo '=================================='

  set +e
  docker exec \
    --user "${user}" \
    "${container_name}" \
      sh -c "/test/run.sh ${coverage_root} ${test_log} ${type} ${@:3}"
  set -e

  # You can't [docker cp] from a tmpfs, so tar-piping coverage out.
  docker exec \
    "${container_name}" \
    tar Ccf \
      "$(dirname "${coverage_root}")" \
      - "$(basename "${coverage_root}")" \
        | tar Cxf "${test_dir}/" -

  set +e
  docker run --rm \
    --volume ${test_dir}/coverage:/app/coverage:ro \
    --volume ${test_dir}/metrics.rb:/app/metrics.rb:ro \
    cyberdojo/check-test-results:latest \
    sh -c "ruby /app/check_test_results.rb /app/coverage/${test_log} /app/coverage/index.html" \
      | tee -a ${test_dir}/coverage/${test_log}
  local -r status=${PIPESTATUS[0]}
  set -e

  echo "Test reports copied to test/${type}/coverage/"
  echo "${type} test status == ${status}"
  if [ "${status}" != '0' ]; then
    docker logs "${container_name}"
  fi
  return ${status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_server_tests() { run_tests nobody server "${@}"; }
run_client_tests() { run_tests nobody client "${@}"; }

# - - - - - - - - - - - - - - - - - - - - - - - - - -
echo
if [ "${1}" == 'server' ]; then
  shift
  run_server_tests "${@}"
elif [ "${1}" == 'client' ]; then
  shift
  run_client_tests "${@}"
else
  run_server_tests "${@}"
  run_client_tests "${@}"
fi
echo All passed
