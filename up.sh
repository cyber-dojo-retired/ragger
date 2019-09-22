#!/bin/bash

export RUBYOPT='-W2'

rackup             \
  --env production \
  --host 0.0.0.0   \
  --port 5537      \
  --server thin    \
  --warn           \
    config.ru
