#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TYPE="${1}" # client|server
shift
readonly TEST_FILES=(${MY_DIR}/${TYPE}/*_test.rb)
readonly TEST_ARGS=(${*})
readonly TEST_LOG=${COVERAGE_ROOT}/test.log
readonly TEST_LOG_PART=${COVERAGE_ROOT}/test.log.part

readonly SCRIPT="
require 'ruby-prof'
GC.disable
RubyProf.start
require '${MY_DIR}/coverage.rb'
%w(${TEST_FILES[*]}).shuffle.each{ |file|
  require file
}
result = RubyProf.stop
def print_profile(result, kind, name)
  kind.new(result).print(File.open(\"${COVERAGE_ROOT}/profile.#{name}.log\",'w+'))
end
print_profile(result, RubyProf::FlatPrinter, 'flat')
#print_profile(result, RubyProf::GraphPrinter, 'graph')
#print_profile(result, RubyProf::CallStackPrinter, 'call_stack')"

export RUBYOPT='-W2'
mkdir -p ${COVERAGE_ROOT}

ruby -e "${SCRIPT}" -- ${TEST_ARGS[@]} \
  2>&1 | tee ${TEST_LOG} ${TEST_LOG_PART}

ruby ${MY_DIR}/check_test_results.rb \
  ${TYPE} \
  ${TEST_LOG_PART} \
  ${COVERAGE_ROOT}/index.html \
    2>&1 | tee -a ${TEST_LOG}

exit ${PIPESTATUS[0]}
