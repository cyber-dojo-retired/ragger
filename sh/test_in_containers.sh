#!/bin/bash
set -e

readonly root_dir="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
readonly my_name=ragger

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_tests()
{
  local -r coverage_root=/tmp/coverage
  local -r user="${1}"                           # eg nobody
  local -r test_dir="test/${2}"                  # eg test/server
  local -r container_name="test-${my_name}-${2}" # eg test-ragger-server

  set +e
  docker exec \
    --user "${user}" \
    --env COVERAGE_ROOT=${coverage_root} \
    "${container_name}" \
      sh -c "/app/test/${2}/util/run.sh ${@:3}"
  local -r status=$?
  set -e

  # You can't [docker cp] from a tmpfs,
  # so tar-piping coverage out.
  docker exec \
    "${container_name}" \
    tar Ccf \
      "$(dirname "${coverage_root}")" \
      - "$(basename "${coverage_root}")" \
        | tar Cxf "${root_dir}/${test_dir}/" -

  echo "Coverage report copied to ${test_dir}/coverage/"
  echo "${2} test status == ${status}"
  return ${status}
}

# - - - - - - - - - - - - - - - - - - - - - - - - - -
run_server_tests() { run_tests nobody server "${*}"; }
run_client_tests() { run_tests nobody client "${*}"; }

# - - - - - - - - - - - - - - - - - - - - - - - - - -
echo
if [ "${1}" == 'server' ]; then
  shift
  run_server_tests "$@"
elif [ "${1}" == 'client' ]; then
  shift
  run_client_tests "$@"
else
  run_server_tests "$@"
  run_client_tests "$@"
fi
echo All passed
