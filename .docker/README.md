# Containerized workflow

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (Mac/Windows) or
  [Docker CE](https://docs.docker.com/install/) (Linux)
- [docker-compose](https://docs.docker.com/compose/install/)
  (Linux only - included in Docker Desktop for Mac/Windows)
- [source-to-image](https://github.com/openshift/source-to-image#installation)

## Wrapper scripts

The `.docker` directory contains wrapper scripts and other files for building
the application image locally and running development and test environments.
Details of usage are given below.

## Build

For iterative development, a build should be run whenever there is a change in
gem dependencies (Gemfile.lock).  Other changes in source code may only require a
restart of the `app` container (or of the rails server within the container).

In the `.docker` directory, run:

    $ ./build.sh [--incremental] [--copy/-c] [-p always]

- Use the `--incremental` flag to re-use artifacts (i.e., gems) from the previous build,
  if available. (Obviously on the first build it will not be able to do this, so you will
  see a non-fatal error message accordingly.)
- Use the `--copy` or `-c` flag to use the local working copy of your code, rather than
  the last commit.  This is useful for iterative development where re-building is
  necessary and you may not want to commit changes before testing.
- Use `-p always` to ensure you get the latest version of the builder image as the
  base for your build.  It's a good idea to do this every so often.

## Development

To run the development environment using the latest (local) build, in the `.docker` directory, run:

    $ ./dev.sh up

You may wish to add the `-d` option to push the process to the background; note, however, that services
may not be fully available as soon as the script exits; Docker considers a service "up" when the
container has started, not necessarily when the main process (e.g., Rails server, Postgres, etc.)
is ready to fully initialized.

For more information, run `./dev.sh --help`.

To access an interactive shell in the `app` container run the `bash` command:

    $ ./dev.sh exec app bash

You will see a prompt like:

    app-user@d9988b05920c:/opt/app-root$

The working directory will be the root of the Rails project, so you
can run rake tasks from that point, or access the Rails console:

    app-user@d9988b05920c:/opt/app-root$ bundle exec rails c

Note that you are logged in as the user `app-user` (UID 1001), which is a member of the `root`
group (GID 0).

To stop the development environment:

    $ ./dev.sh down

## Test

For iterative development, it may be useful to start the test environment. The Rails and Solr
ports are not published by default; it is assumed that you will be using the command line
in the `app` container to run tests, e.g.:

    $ ./test.sh run --rm app bash

To run the test suite:

    $ ./run_test_suite.sh

To ensure that the test environment is cleaned up run:

    $ ./test.sh down

Fore more information, run `./test.sh --help`.
