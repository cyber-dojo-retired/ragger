#!/bin/bash

cat_env_vars()
{
  local -r tag=${CYBER_DOJO_VERSION:-latest}
  docker run --rm cyberdojo/versioner:${tag} sh -c 'cat /app/.env'
}

export -f cat_env_vars
