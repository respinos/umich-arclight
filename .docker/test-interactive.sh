#!/bin/bash
#
# Run an interactive test environment with the
# local code mounted in the app container.
#
context=$(git rev-parse --show-toplevel)
cd "$(dirname ${BASH_SOURCE[0]})"
./test.sh run --rm -v "${context}:/opt/app-root" app bash
./test.sh down
