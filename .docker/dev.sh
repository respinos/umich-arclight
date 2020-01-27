#!/usr/bin/env bash

export COMPOSE_PROJECT_NAME=arclight-dev
export RAILS_ENV=development

if [[ "$@" =~ ^(-h|(--)?help)$ ]]; then
    cat <<EOF

Docker Compose wrapper script for development environment.

    $ ./dev.sh COMMAND

See 'docker-compose COMMAND --help' for details on commands and options.

Examples:

    Start the development environment [-d in the background]:

    $ ./dev.sh up [-d]

    Stop the development environment:

    $ ./dev.sh down

    Run an interactive bash shell in the 'app' container:

    $ ./dev.sh exec app bash

    Run a (non-interactive) rake task in the 'app' container:

    $ ./dev.sh exec app bundle exec rake TASK

EOF
    exit 0
fi

cd "$(dirname ${BASH_SOURCE[0]})"
docker-compose -f docker-compose.yml -f docker-compose.dev.yml "$@"
