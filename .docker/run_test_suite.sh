#!/usr/bin/env bash

IFS='' read -r -d '' USAGE <<EOF
Wrapper script for running test suite with clean database.

    $ ./run_test_suite.sh
EOF

if [[ "$@" =~ ^(-h|(--)?help)$ ]]; then
    echo "$USAGE"
    exit 0
fi

cd "$(dirname ${BASH_SOURCE[0]})"
./test.sh run --rm app bundle exec rake db:reset spec
code=$?
./test.sh down
exit $code
