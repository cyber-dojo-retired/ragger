#!/bin/bash
set -e

export RUBYOPT='-W2'

rackup \
  --warn \
  --host 0.0.0.0 \
  --port 5538 \
  --server thin \
  --env production \
    /app/config.ru
