#!/bin/bash

detagged_url()
{
  # https://github.com/a/b/name.git          ==> "https://github.com/a/b/name.git"
  # https://github.com/a/b/name.git?tag3.7.4 ==> "https://github.com/a/b/name.git"
  echo ${1%\?*}
}

url_tag()
{
  # https://github.com/a/b/name.git          ==> ""
  # https://github.com/a/b/name.git?tag3.7.4 ==> "3.7.4"
  local -r detagged=$(detagged_url $1)
  local -r len=${#detagged}+1
  local -r tag=${1:${len}:999}
  echo ${tag##*tag=}
}

url="https://github.com/cyber-dojo-languages/python-unittest.git?tag=3.7.4"
echo
echo '----------------------------------'
echo ".....url:${url}:"
echo "detagged:$(detagged_url $url):"
echo "...value:$(url_tag $url):"

url="https://github.com/cyber-dojo-languages/python-unittest.git"
echo
echo '----------------------------------'
echo ".....url:${url}:"
echo "detagged:$(detagged_url $url):"
echo "...value:$(url_tag $url):"
