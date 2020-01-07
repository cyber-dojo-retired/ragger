#!/bin/bash -Eeu

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TYPE="${1}" # client|server
shift
readonly TEST_FILES=(${MY_DIR}/${TYPE}/*_test.rb)
readonly TEST_ARGS=(${*})
readonly TEST_LOG=test.log

readonly SCRIPT="
require '${MY_DIR}/coverage.rb'
%w(${TEST_FILES[*]}).shuffle.each{ |file|
  require file
}"

export RUBYOPT='-W2'
mkdir -p ${COVERAGE_ROOT}

set +e
ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} 2>&1 | tee ${COVERAGE_ROOT}/${TEST_LOG}
set -e
