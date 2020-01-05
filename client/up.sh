#!/bin/bash -Eeu

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

export RUBYOPT='-W2'

rackup \
  --warn \
  --host 0.0.0.0 \
  --port 5538 \
  --server thin \
  --env production \
  ${MY_DIR}/config.ru
