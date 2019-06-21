#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TEST_FILES=(${MY_DIR}/../*_test.rb)
readonly TEST_ARGS=(${*})
readonly TEST_LOG=${COVERAGE_ROOT}/test.log

readonly SCRIPT="([ '${MY_DIR}/coverage.rb' ] + %w(${TEST_FILES[*]})).each{ |file| require file }"

export RUBYOPT=-w
mkdir -p ${COVERAGE_ROOT}
ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} 2>&1 | tee ${TEST_LOG}

ruby ${MY_DIR}/check_test_results.rb \
  ${TEST_LOG} \
  ${COVERAGE_ROOT}/index.html \
    > ${COVERAGE_ROOT}/done.txt


# I tried to add profiling.
# cyberdojo/rack-base installs ruby-prof gem.
#
#echo "${SCRIPT}" > /tmp/test_run.rb
#ruby-prof \
#   --min_percent=0.05 \
#   --printer=flat \
#   --file=${COVERAGE_ROOT}/profiled.test_run.dump \
#   /tmp/test_run.rb \
#   ${TEST_ARGS[@]} | tee ${TEST_LOG}

# This fails and the reason seems to be that TEST_LOG
# is being buffered so is not fully written when the
# check_test_results.rb script runs.
