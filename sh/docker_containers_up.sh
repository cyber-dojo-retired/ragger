#!/bin/bash
set -e

# - - - - - - - - - - - - - - - - - - - -
ip_address_slow()
{
  if [ -n "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip ${DOCKER_MACHINE_NAME}
  else
    echo localhost
  fi
}
readonly IP_ADDRESS=$(ip_address_slow)

# - - - - - - - - - - - - - - - - - - - -
wait_until_ready()
{
  local -r name="${1}"
  local -r port="${2}"
  local -r max_tries=10
  printf "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries})
  do
    printf '.'
    if ready ${port}; then
      printf 'OK\n'
      return
    else
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  printf "${name} not ready after ${max_tries} tries\n"
  if [ -f "$(ready_filename)" ]; then
    printf "$(cat "$(ready_filename)")\n"
  fi
  docker logs ${name}
  exit 42
}

# - - - - - - - - - - - - - - - - - - - -
ready()
{
  local -r port="${1}"
  local -r path=ready?
  local -r curl_cmd="curl --fail --output $(ready_filename) --silent -X GET http://${IP_ADDRESS}:${port}/${path}"
  rm -f "$(ready_filename)"
  if ${curl_cmd} && [ "$(cat "$(ready_filename)")" = '{"ready?":true}' ]; then
    true
  else
    false
  fi
}

ready_filename()
{
  printf /tmp/curl-ready-output
}

# - - - - - - - - - - - - - - - - - - - -
wait_till_up()
{
  local n=10
  while [ $(( n -= 1 )) -ge 0 ]
  do
    if docker ps --filter status=running --format '{{.Names}}' | grep -q ^${1}$ ; then
      return
    else
      sleep 0.5
    fi
  done
  printf "${1} not up after 5 seconds\n"
  docker logs "${1}"
  exit 42
}

# - - - - - - - - - - - - - - - - - - - -
exit_unless_clean()
{
  local -r name="${1}"
  local -r docker_log=$(docker logs "${name}" 2>&1)
  local -r line_count=$(echo -n "${docker_log}" | grep -c '^')
  printf "Checking ${name} started cleanly..."
  if [ "${line_count}" == '3' ]; then
    printf 'OK\n'
  else
    printf 'FAIL\n'
    print_docker_log "${name}" "${docker_log}"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - -
print_docker_log()
{
  local -r name="${1}"
  local -r docker_log="${2}"
  printf "[docker logs ${name}]\n"
  printf '<docker_log>\n'
  printf "${docker_log}\n"
  printf '</docker_log>\n'
}

# - - - - - - - - - - - - - - - - - - - -
readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export NO_PROMETHEUS=true

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  --detach \
  --force-recreate

wait_until_ready  test-ragger-server 5537
exit_unless_clean test-ragger-server

wait_until_ready  test-ragger-runner-server 4597
exit_unless_clean test-ragger-runner-server

wait_till_up      test-ragger-client
