#!/bin/bash

APP_IMAGE=${APP_IMAGE:-dul-arclight}
BUILD_CONTEXT="file://$(git rev-parse --show-toplevel)"
BUILDER_IMAGE=${BUILDER_IMAGE:-gitlab-registry.oit.duke.edu/devops/containers/images/rails/ruby26:latest}
BUILD_OPTS=( "$@" )

if ! [[ "${BUILD_OPTS[@]}" =~ (-c|--copy) ]] && \
	! git diff-index --quiet HEAD -- ; then
    BUILD_OPTS+=( -c )
fi

# handle incremental option
if [[ ! "${BUILD_OPTS[@]}" =~ --incremental ]] && \
       [[ -n "$(docker image ls -q ${APP_IMAGE})" ]]; then
    BUILD_OPTS+=( --incremental )
fi

# pull policy
if [[ ! "${BUILD_OPTS[@]}" =~ (-p|--pull-policy) ]]; then
    BUILD_OPTS+=( -p always )
fi

[[ -n "${BUILD_OPTS[@]}" ]] && echo "s2i build options: ${BUILD_OPTS[@]}"

echo "---> Building runtime image ..."
SECONDS=0

if s2i build ${BUILD_CONTEXT} ${BUILDER_IMAGE} ${APP_IMAGE} ${BUILD_OPTS[@]}; then
   echo "Image successfully built in $SECONDS seconds."
fi
