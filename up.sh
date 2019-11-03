#!/bin/bash

export RUBYOPT='-W2'

rackup \
  --env production  \
  --port 5537       \
  --server thin     \
  --warn            \
    config.ru
