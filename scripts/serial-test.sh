#!/bin/bash
set -eo pipefail
# prepare environment
PATH=$PATH:~/opt/mongodb/bin
echo "[Extracting build directory]"
[[ -z "${1}" ]] && tar -zxf build.tar.gz || tar -xzf $1
cd ./build
# run tests
echo "[Running tests]"
set +e # defer ctest error handling to end
ctest -L nonparallelizable_tests --output-on-failure -T Test
EXIT_STATUS=$?
[[ "$EXIT_STATUS" == 0 ]] && set -e
mv $(pwd)/Testing/$(ls $(pwd)/Testing/ | grep '20' | tail -n 1)/Test.xml test-results.xml
# ctest error handling
[[ "$EXIT_STATUS" != 0 ]] && echo "Failing due to non-zero exit status from ctest: $EXIT_STATUS" && exit $EXIT_STATUS