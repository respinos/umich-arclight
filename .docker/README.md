# Containerized workflow

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (Mac/Windows) or
  [Docker CE](https://docs.docker.com/install/) (Linux)
- [docker-compose](https://docs.docker.com/compose/install/)
  (Linux only - included in Docker Desktop for Mac/Windows)
- [source-to-image](https://github.com/openshift/source-to-image#installation)
- [GNU Make](https://www.gnu.org/software/make/) - Mac can get in XCode
  Command Line Tools (CLT) or via Home Brew.

## Wrapper scripts

The `.docker` directory contains wrapper scripts and other files for
running development and test environments.
Details of usage are given below.

## Build

For iterative development, a build should be run whenever there is a change in
gem dependencies (Gemfile.lock).  Other changes in source code may only require a
restart of the `app` container (or of the rails server within the container).

    $ make

The standard build process will pull the base image, inject the application
source directory, and copy gems from a previous if available.

## Development

To run the development environment using the latest (local) build, in the `.docker` directory, run:

    $ ./dev.sh up

You may wish to add the `-d` option to push the process to the background; note, however, that services
may not be fully available as soon as the script exits; Docker considers a service "up" when the
container has started, not necessarily when the main process (e.g., Rails server, Postgres, etc.)
is ready to fully initialized.

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

(You should use this command if you interrupted the stack running the foreground
with Ctrl-C.)

## Test

For iterative development, it may be useful to run the test environment interactively:

    $ ./test-interactive.sh

This command will drop you into an interactive bash shell in the `app` container
with your local code mounted in the application root directory.

From there, you can run various `rspec` commands or the whole test suite (`bundle exec rake spec`).

WHen you exit the interactive test environment, the test stack will shut down.

To run the test suite using the *latest build*, not including subsequent changes, run:

    $ make test

This command is intended primarily for CI usage.
