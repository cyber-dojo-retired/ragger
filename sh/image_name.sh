#!/bin/bash
set -e

image_name()
{
  echo "${CYBER_DOJO_RAGGER_IMAGE}"
}

export image_name
