#!/bin/bash

readonly SH_DIR="$( cd "$( dirname "${0}" )" && cd .. && pwd )/sh"
source ${SH_DIR}/cat_env_vars.sh
readonly VERSION=${1:-latest}
export $(cat_env_vars ${VERSION})

"${SH_DIR}/build_images.sh"
"${SH_DIR}/containers_up.sh"
source ${SH_DIR}/ip_address.sh
open "http://$(ip_address):5538"
#"${SH_DIR}/containers_down.sh"
