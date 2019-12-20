#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
source ${ROOT_DIR}/sh/ip_address.sh
readonly IP_ADDRESS=$(ip_address)

# - - - - - - - - - - - - - - - - - - - -
wait_until_ready()
{
  local -r name="${1}"
  local -r port="${2}"
  local -r max_tries=10
  printf "Waiting until ${name} is ready"
  for _ in $(seq ${max_tries}); do
    printf '.'
    if ready ${port}; then
      printf 'OK\n'
      return
    else
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  echo "${name} not ready after ${max_tries} tries"
  if [ -f "$(ready_filename)" ]; then
    cat "$(ready_filename)"
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

# - - - - - - - - - - - - - - - - - - - -
ready_filename()
{
  printf /tmp/curl-ready-output
}

# - - - - - - - - - - - - - - - - - - - -
wait_till_up()
{
  local -r name="${1}"
  local -r max_tries=10
  for _ in $(seq ${max_tries}); do
    if running_container "${name}" ; then
      return
    else
      sleep 0.5
    fi
  done
  echo "${1} not running after ${max_tries} tries"
  docker logs "${name}"
  exit 42
}

# - - - - - - - - - - - - - - - - - - - -
running_container()
{
  local -r name="${1}"
  docker ps \
    --all \
    --filter status=running \
    --filter name="^/${name}$" \
    --format '{{.Names}}' \
    --no-trunc
}

# - - - - - - - - - - - - - - - - - - - -
exit_unless_clean()
{
  local -r name="${1}"
  local -r docker_log=$(docker logs "${name}" 2>&1)
  local -r line_count=$(echo -n "${docker_log}" | grep --count '^')
  printf "Checking ${name} started cleanly..."
  if [ "${line_count}" == '3' ]; then
    printf 'OK\n'
  else
    printf 'FAIL\n'
    echo_docker_log "${name}" "${docker_log}"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - -
echo_docker_log()
{
  local -r name="${1}"
  local -r docker_log="${2}"
  echo "[docker logs ${name}]"
  echo '<docker_log>'
  echo "${docker_log}"
  echo '</docker_log>'
}

# - - - - - - - - - - - - - - - - - - - -
export NO_PROMETHEUS=true

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
  up \
  --detach \
  --force-recreate

wait_until_ready  test-ragger-server 5537
exit_unless_clean test-ragger-server

wait_till_up      test-ragger-client
