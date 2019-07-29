#!/bin/bash
set -e

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )"
export SHA=$(cd "${ROOT_DIR}" && git rev-parse HEAD)

docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
    build \
      ragger

echo
docker-compose \
  --file "${ROOT_DIR}/docker-compose.yml" \
    build \
      ragger-client

# Assuming we do not have any new ragger commits, ragger's latest commit
# sha will match the image tag inside versioner's .env file.
# This means we can tag to it and a [cyber-dojo up] call
# will use the tagged image.
docker tag cyberdojo/ragger:latest cyberdojo/ragger:${SHA:0:7}
