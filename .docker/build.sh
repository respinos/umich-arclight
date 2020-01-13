#!/bin/bash
BUILDER_IMAGE=gitlab-registry.oit.duke.edu/devops/containers/rails:latest
s2i build .. ${BUILDER_IMAGE} ${APP_IMAGE:-dul-arclight} "$@"
