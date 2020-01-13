#!/usr/bin/env bash
export COMPOSE_PROJECT_NAME=arclight-test
docker-compose -f docker-compose.yml -f docker-compose.test.yml "$@"
