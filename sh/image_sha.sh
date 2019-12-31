#!/bin/bash -Ee

image_sha()
{
  docker run --rm ${CYBER_DOJO_RAGGER_IMAGE}:latest sh -c 'echo ${SHA}'
}
