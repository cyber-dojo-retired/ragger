#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"
readonly COVERAGE_ROOT=/tmp/coverage

bring_live_volume_mount_container_up()
{
  "${SH_DIR}/set_tag_env_vars.sh"
  set -a
  source /tmp/versioner.ragger.env
  set +a

  docker-compose \
    --file "${SH_DIR}/../docker-compose-non-rebuild.yml" \
    up \
    -d \
    --force-recreate
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if ! docker ps --all | grep --quiet test-ragger-server ; then
  bring_live_volume_mount_container_up
  sleep 1
fi

docker exec \
  --user nobody \
  --env COVERAGE_ROOT=${COVERAGE_ROOT} \
  test-ragger-server \
    sh -c "/app/test/util/run.sh ${*}"
