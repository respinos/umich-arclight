#!/usr/bin/env bash

if [[ "$@" =~ ^(-h|(--)?help)$ ]]; then
    cat <<EOF

Wrapper script for running test suite with clean database.

    $ ./run_test_suite.sh

EOF
    exit 0
fi

cd "$(dirname ${BASH_SOURCE[0]})"
./test.sh run --rm app bundle exec rubocop
./test.sh run --rm app bundle exec rake seed:fixtures
./test.sh run --rm app bundle exec rake db:reset spec
code=$?
./test.sh down
exit $code
