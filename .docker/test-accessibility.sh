#!/bin/bash

cd "$(dirname ${BASH_SOURCE[0]})"
./test.sh run --use-aliases --entrypoint "wait-for-it solr:8983 --" app \
	  bundle exec rake dul_arclight:test:accessibility
code=$?
./test.sh down
exit $code
