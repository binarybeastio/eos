#!/bin/bash
set -eo pipefail
echo "[Extracting build directory]"
[[ -z "${1}" ]] && tar -zxf build.tar.gz || tar -xzf $1
cd ./build
echo "[Running tests]"
set +e # defer ctest error handling to end
ctest -j $(getconf _NPROCESSORS_ONLN) -LE _tests --output-on-failure -T Test
EXIT_STATUS=$?
[[ "$EXIT_STATUS" == 0 ]] && set -e
# Prepare tests for artifact upload
mv $(pwd)/Testing/$(ls $(pwd)/Testing/ | grep '20' | tail -n 1)/Test.xml test-results.xml
# ctest error handling
[[ "$EXIT_STATUS" != 0 ]] && echo "Failing due to non-zero exit status from ctest: $EXIT_STATUS" && exit $EXIT_STATUS