#!/bin/bash
set -e

docker run --rm \
  cyberdojo/versioner:${CYBER_DOJO_VERSIONER_TAG:-latest} \
    sh -c 'cat /app/.env' \
      > /tmp/versioner.ragger.env
