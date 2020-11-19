#!/bin/bash

cd "$(dirname ${BASH_SOURCE[0]})"
docker-compose -f docker-compose.yml \
	       -f docker-compose.dev.yml \
	       -p dul-arclight-dev \
	       "$@"
