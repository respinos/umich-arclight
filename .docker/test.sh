#!/usr/bin/env bash

export COMPOSE_PROJECT_NAME=arclight-test
export RAILS_ENV=test

if [[ "$@" =~ ^(-h|(--)?help)$ ]]; then
    cat <<EOF
Docker Compose wrapper script for test environment.

    $ ./test.sh COMMAND

See 'docker-compose COMMAND --help' for details on commands and options.

Examples:

    Start the test environment [-d in the background]:

    $ ./test.sh up [-d]

    Stop the test environment:

    $ ./test.sh down

    Start an interactive bash shell in the running 'app' container:

    $ ./test-interactive.sh

    Run a (non-interactive) rake task in the running 'app' container:

    $ ./test.sh exec app bundle exec rake TASK

EOF
    exit 0
fi

cd "$(dirname ${BASH_SOURCE[0]})"
docker-compose -f docker-compose.yml -f docker-compose.test.yml "$@"
