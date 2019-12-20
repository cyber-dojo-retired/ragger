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
    if curl_ready "${port}"; then
      printf '.OK\n'
      return
    else
      printf '.'
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  echo "not ready after ${max_tries} tries"
  if [ -f "$(ready_filename)" ]; then
    cat "$(ready_filename)"
  fi
  docker logs ${name}
  exit 42
}

# - - - - - - - - - - - - - - - - - - - -
curl_ready()
{
  local -r port="${1}"
  local -r path=ready?
  local -r url="http://${IP_ADDRESS}:${port}/${path}"
  rm -f "$(ready_filename)"
  curl \
    --fail \
    --output $(ready_filename) \
    --silent \
    -X GET \
    "${url}"
  [ "$?" == '0' ] && [ "$(cat "$(ready_filename)")" == '{"ready?":true}' ]
}

# - - - - - - - - - - - - - - - - - - - -
ready_filename()
{
  printf /tmp/curl-ready-output
}

# - - - - - - - - - - - - - - - - - - - -
wait_until_running()
{
  local -r name="${1}"
  local -r max_tries=10
  printf "Waiting until ${name} is running"
  for _ in $(seq ${max_tries}); do
    if running_containers | grep --quiet "^${name}$"; then
      printf '.OK\n'
      return
    else
      printf .
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  echo "not running after ${max_tries} tries"
  docker logs "${name}"
  exit 42
}

# - - - - - - - - - - - - - - - - - - - -
running_containers()
{
  docker ps \
    --all \
    --filter status=running \
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

wait_until_running test-ragger-client
