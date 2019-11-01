#!/bin/bash

export RACK_ENV=production
export RUBYOPT='-W2'
rackup --warn --port 5537 config.ru
