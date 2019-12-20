#!/bin/bash
set -e

# - - - - - - - - - - - - - - - - - - - - - - - -
tag_the_image()
{
  local -r IMAGE="$(image_name)"
  local -r SHA="$(image_sha)"
  local -r cmd="docker tag ${IMAGE}:latest ${IMAGE}:${SHA:0:7}"
  eval ${cmd}
  echo "${cmd}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CIRCLECI}" ]
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_pull_dependent_images()
{
  # Otherwise it interferes with timing tests
  if on_ci; then
    docker pull cyberdojofoundation/python_pytest
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - -
on_ci_publish_tagged_images()
{
  if ! on_ci; then
    echo 'not on CI so not publishing tagged images'
    return
  fi
  echo 'on CI so publishing tagged images'
  local -r IMAGE="$(image_name)"
  local -r SHA="$(image_sha)"
  # DOCKER_USER, DOCKER_PASS are in ci context
  echo "${DOCKER_PASS}" | docker login --username "${DOCKER_USER}" --password-stdin
  docker push ${IMAGE}:latest
  docker push ${IMAGE}:${SHA:0:7}
  docker logout
}

# - - - - - - - - - - - - - - - - - - - - - - - -
readonly SH_DIR="$( cd "$( dirname "${0}" )" && pwd )/sh"
source ${SH_DIR}/cat_env_vars.sh
export $(cat_env_vars)

${SH_DIR}/build_images.sh
${SH_DIR}/containers_up.sh
on_ci_pull_dependent_images
${SH_DIR}/run_tests_in_containers.sh "$@"
${SH_DIR}/containers_down.sh

source ${SH_DIR}/image_name.sh
source ${SH_DIR}/image_sha.sh
tag_the_image
on_ci_publish_tagged_images
