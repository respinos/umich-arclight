#!/bin/bash

BUILDER_IMAGE=gitlab-registry.oit.duke.edu/devops/containers/rails-ruby26:latest
BUILD_CONTEXT=$(git rev-parse --show-toplevel)

if [[ "$@" =~ ^(-h|(--)?help)$ ]]; then
    cat <<EOF

Build a container image for the project based on the latest commit.

    ./build.sh [--incremental]

Use the '--incremental' flag to re-use artifacts from the previous build.

EOF
    exit 0
fi

if ! [[ "$@" =~ (-c|--copy) ]]; then
    if ! git diff-index --quiet HEAD -- ; then
        cat <<EOF

WARNING: You have uncommitted changes in your working tree.

The build will be based on the latest commit:

    $(git log --pretty=oneline | head -1)

(Use the -c/--copy option with caution to build from the working directory as is.)

EOF
        echo -n "Continue (y/N)? "
        read answer
        if [ "${answer}" != "y" ]; then
            echo -e "\nBuild aborted.\n"
            exit 0
        fi
    fi
fi

s2i build \
    file://${BUILD_CONTEXT} \
    ${BUILDER_IMAGE} \
    ${APP_IMAGE:-dul-arclight} \
    "$@"
