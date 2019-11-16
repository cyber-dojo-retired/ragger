#!/bin/bash
set -e

readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"
readonly TAG=${CYBER_DOJO_VERSIONER_TAG:-latest}

source ${SH_DIR}/cat_env_vars.sh
export $(cat_env_vars ${TAG})

${SH_DIR}/build_docker_images.sh
${SH_DIR}/docker_containers_up.sh
if ${SH_DIR}/run_tests_in_containers.sh "$@" ; then
  ${SH_DIR}/docker_containers_down.sh
  exit 0
else
  exit 3
fi
