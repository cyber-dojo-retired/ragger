#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"

"${SH_DIR}/set_tag_env_vars.sh"
set -a
source /tmp/versioner.ragger.env
set +a

${SH_DIR}/build_docker_images.sh
${SH_DIR}/docker_containers_up.sh
if ${SH_DIR}/run_tests_in_containers.sh "$@" ; then
  ${SH_DIR}/docker_containers_down.sh
  exit 0
else
  exit 3
fi
