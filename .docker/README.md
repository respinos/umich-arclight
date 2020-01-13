# Containerized workflow

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (Mac/Windows) or
  [Docker CE](https://docs.docker.com/install/) (Linux)
- [docker-compose](https://docs.docker.com/compose/install/)
  (Linux only - included in Docker Desktop for Mac/Windows)
- [source-to-image](https://github.com/openshift/source-to-image#installation)

## Build

For iterative development, a build should be run whenever there is a change in
gem dependencies (Gemfile.lock).  Other changes in source code may only require a
restart of the `app` container (or of the rails server within the container).

In the `.docker` directory, run:

    $ ./build.sh

The script attempts to do an [incremental build](https://github.com/openshift/source-to-image#incremental-builds)
by re-using artifacts (i.e., gems) from the previous build, if available.
Obviously on the first build it will not be able to do this, so you will
see a message accordingly.  Subsequent builds will usually be able to
retrieve artifacts, saving build time.

## Development

To run the development environment using the latest (local) build, in the `.docker` directory, run:

    $ ./dev.sh up

You may wish to add the `-d` option to push the process to the background; note, however, that services
may not be fully available as soon as the script exits; Docker considers a service "up" when the
container has started, not necessarily when the main process (e.g., Rails server, Postgres, etc.)
is ready to fully initialized.

To access a command prompt in the `app` container run:

    $ ./dev.sh exec app bash

You will see a prompt like:

    app-user@d9988b05920c:~$

The working directory will be the root of the Rails project. You can run rake tasks from that point,
or access the Rails console:

    app-user@d9988b05920c:~$ bundle exec rails c

To stop the development environment:

    $ ./dev.sh down

## Test

For iterative development, it may be useful to start the test environment. The Rails and Solr
ports are not published by default; it is assumed that you will be using the command line
in the `app` container to run tests, e.g.:

    $ ./test.sh run --rm app bash

To run the test suite:

    $ ./run_test_suite.sh
