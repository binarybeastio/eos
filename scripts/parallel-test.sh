#!/bin/bash
set -eo pipefail
cd ./build
echo "[Running tests]"
set +e # defer ctest error handling to end
ctest -j $(getconf _NPROCESSORS_ONLN) -LE _tests --output-on-failure -T Test
EXIT_STATUS=$?
[[ "$EXIT_STATUS" == 0 ]] && set -e
# Prepare tests for artifact upload
mv ./Testing/$(ls ./Testing/ | grep '20' | tail -n 1)/Test.xml test-results.xml
echo $?
echo $EXIT_STATUS
# ctest error handling
[[ "$EXIT_STATUS" != 0 ]] && echo "Failing due to non-zero exit status from ctest: $EXIT_STATUS" && exit $EXIT_STATUS