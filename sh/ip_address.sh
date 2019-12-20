#!/bin/bash
set -e

ip_address()
{
  if [ ! -z "${DOCKER_MACHINE_NAME}" ]; then
    docker-machine ip "${DOCKER_MACHINE_NAME}"
  else
    echo localhost
  fi
}

export -f ip_address
