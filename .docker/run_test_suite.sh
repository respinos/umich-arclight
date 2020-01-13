#!/usr/bin/env bash
./test.sh run --rm app bundle exec rake db:reset spec
code=$?
./test.sh down
exit $code
