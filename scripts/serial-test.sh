#!/bin/bash
set -eo pipefail
cd ./build
# prepare environment
echo "[Killing old MongoDB]"
$(pgrep mongod | xargs kill -9) || true
echo "[Starting MongoDB]"
PATH=$PATH:~/opt/mongodb/bin
mongod --fork --dbpath ~/data/mongodb -f ~/etc/mongod.conf --logpath ~/var/log/mongodb/mongod.log
# run tests
echo "[Running tests]"
set +e # defer ctest error handling to end
ctest -L nonparallelizable_tests --output-on-failure -T Test
EXIT_STATUS=$?
[[ $EXIT_STATUS == 0 ]] && set -e
echo "[Uploading artifacts]"
mv ./Testing/$(ls ./Testing/ | grep '20' | tail -n 1)/Test.xml test-results.xml
buildkite-agent artifact upload test-results.xml
buildkite-agent artifact upload build/config.ini
buildkite-agent artifact upload build/genesis.json
mv ~/var/log/mongodb/mongod.log mongod.log
buildkite-agent artifact upload mongod.log
# ctest error handling
[[ $EXIT_STATUS != 0 ]] && echo "Failing due to non-zero exit status from ctest: $EXIT_STATUS"; exit $EXIT_STATUS