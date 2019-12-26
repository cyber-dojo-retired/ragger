#!/bin/bash
set -e

readonly ROOT_DIR="$(cd "$( dirname "${0}" )" && cd .. && pwd)"

#- - - - - - - - - - - - - - - - - - - - - - - -
build_images()
{
  docker-compose \
    --file "${ROOT_DIR}/docker-compose.yml" \
    build \
    --build-arg COMMIT_SHA="$(git_commit_sha)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${ROOT_DIR}" && git rev-parse HEAD)
}

# - - - - - - - - - - - - - - - - - - - - - - - -
assert_equal()
{
  local -r name="${1}"
  local -r expected="${2}"
  local -r actual="${3}"
  echo "expected: ${name}='${expected}'"
  echo "  actual: ${name}='${actual}'"
  if [ "${expected}" != "${actual}" ]; then
    echo "ERROR: unexpected ${name} inside image ${IMAGE}:latest"
    exit 42
  fi
}

#- - - - - - - - - - - - - - - - - - - - - - - -
readonly SH_DIR="${ROOT_DIR}/sh"
source ${SH_DIR}/cat_env_vars.sh
readonly VERSION=${1:-latest}
export $(cat_env_vars ${VERSION})
source ${SH_DIR}/image_sha.sh

build_images
assert_equal SHA "$(git_commit_sha)" "$(image_sha)"
