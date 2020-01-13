#!/usr/bin/env bash
export COMPOSE_PROJECT_NAME=arclight-dev
docker-compose -f docker-compose.yml -f docker-compose.dev.yml "$@"
