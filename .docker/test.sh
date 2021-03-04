#!/bin/bash

cd "$(dirname ${BASH_SOURCE[0]})"

docker-compose \
    -p "dul-arclight-${CI_COMMIT_SHORT_SHA:-test}" \
    -f docker-compose.yml \
    -f docker-compose.test.yml \
    "$@"
