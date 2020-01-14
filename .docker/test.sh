#!/usr/bin/env bash

IFS='' read -r -d '' USAGE <<EOF
Docker Compose wrapper script for test environment.

    $ ./test.sh COMMAND

See 'docker-compose COMMAND --help' for details on commands and options.

Examples:

    Start the development environment [-d in the background]:

    $ ./test.sh up [-d]

    Stop the development environment:

    $ ./test.sh down

    Start an interactive bash shell in the running 'app' container:

    $ ./test.sh exec app bash

    Run a (non-interactive) rake task in the running 'app' container:

    $ ./test.sh exec app bundle exec rake TASK
EOF

if [[ "$@" =~ ^(-h|(--)?help)$ ]]; then
    echo "$USAGE"
    exit 0
fi

export COMPOSE_PROJECT_NAME=arclight-test
cd "$(dirname ${BASH_SOURCE[0]})"
docker-compose -f docker-compose.yml -f docker-compose.test.yml "$@"
