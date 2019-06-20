#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TEST_FILES=(${MY_DIR}/../*_test.rb)
readonly TEST_ARGS=(${*})
readonly TEST_LOG=${COVERAGE_ROOT}/test.log

mkdir -p ${COVERAGE_ROOT}

readonly SCRIPT="([ '${MY_DIR}/coverage.rb' ] + %w(${TEST_FILES[*]})).each{ |file| require file }"

#ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} | tee ${TEST_LOG}

echo "${SCRIPT}" > /tmp/test_run.rb
ruby-prof \
   --min_percent=0.05 \
   --printer=flat \
   --file=${COVERAGE_ROOT}/profiled.test_run.dump \
   /tmp/test_run.rb \
   ${TEST_ARGS[@]} | tee ${TEST_LOG}

echo 'flush...' >> ${TEST_LOG}

ruby ${MY_DIR}/check_test_results.rb \
  ${TEST_LOG} \
  ${COVERAGE_ROOT}/index.html \
    > ${COVERAGE_ROOT}/done.txt
