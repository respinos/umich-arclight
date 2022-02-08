# Kubernetes workflow

## K8s (local)
docker image build loop for k8s:
- In the relevant k8s yaml files, set `imagePullPolicy: Never`
- for the app base image:
    - modify .docker/Dockerfile.staging
    - `$ docker build -t umich-arclight-staging:<tag> -f .docker/Dockerfile.staging .`
    - `$ docker run umich-arclight-staging:<tag>` (to sanity-check)
    - `$ minikube image load umich-arclight-staging:<tag>`
    - set tag in .docker/dev-k8s/app-deployment.yaml spec->template->spec->containers->image
    - `$ kubectl apply -f .docker/dev-k8s/app-deployment.yaml`
- for the solr image:
    - modify .docker/Dockerfile.solr.staging
    - `$ docker build -t umich-arclight-solr-staging:<tag> -f .docker/Dockerfile.staging .`
    - `$ docker run umich-arclight-solr-staging:<tag>` (to sanity-check)
    - `$ minikube image load umich-arclight-solr-staging:<tag>`
    - set tag in .docker/dev-k8s/solr-deployment.yaml spec->template->spec->containers->image
    - `$ kubectl apply -f .docker/dev-k8s/solr-deployment.yaml`
- Check out lens to see what’s broken this time

## K8s (staging)
- Requires access to a dockerhub or other docker image repository
- `$ docker build -t umich-arclight-solr-staging:<tag> -f .docker/Dockerfile.solr.staging .`
- `$ docker image tag umich-arclight-solr-staging:<tag> <repository>/umich-arclight-solr-staging:<tag>`
- `$ docker image push <repository>>/umich-arclight-solr-staging:<tag>`
- `$ docker build -t umich-arclight-staging:<tag> -f .docker/Dockerfile.staging`
- `$ docker image tag umich-arclight-staging:<tag> <repository>/umich-arclight-staging:<tag>`
- `$ docker image push <repository>/umich-arclight-staging:<tag>`
- Update image tags in app-deployment-staging.yaml and solr-deployment-staging.yaml
- `$ kubectl --namespace=arclight-testing apply -f .docker/base-k8s/ -f .docker/remote-k8s -f .docker/staging-k8s/`
    - If you haven't set up the persistent volume claims you will also need to apply `.docker/pvc-k8s`


# Containerized workflow

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) (Mac/Windows) or
  [Docker CE](https://docs.docker.com/install/) (Linux)
- [docker-compose](https://docs.docker.com/compose/install/)
  (Linux only - included in Docker Desktop for Mac/Windows)
- [source-to-image](https://github.com/openshift/source-to-image#installation)
- [GNU Make](https://www.gnu.org/software/make/) - Mac can get in XCode
  Command Line Tools (CLT) or via Home Brew.

## Update Feb 8 2022
Start docker compose with
```bash
$ docker-compose -f docker-compose.dev.yml up
```

Index EADs with
```bash
$ SOLR_URL=http://localhost:8983/solr/arclight FINDING_AID_DATA=./sample-ead bundle exec rake dul_arclight:reindex_all
```

May also need db migrations:
```bash
$ docker-compose -f docker-compose.dev.yml exec -- app bundle exec bin/rails db:migrate RAILS_ENV=development
```

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
