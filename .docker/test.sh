#!/bin/bash

cd "$(dirname ${BASH_SOURCE[0]})"

docker-compose \
    -p "dul-arclight-${PROJECT_SUFFIX:-test}" \
    -f docker-compose.yml \
    -f docker-compose.test.yml \
    "$@"
