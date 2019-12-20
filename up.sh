#!/bin/bash

export RUBYOPT='-W2'

rackup \
  --env production  \
  --port ${PORT}    \
  --server thin     \
  --warn            \
    config.ru
