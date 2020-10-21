SHELL = /bin/bash

build_tag ?= dul-arclight
builder_image ?= gitlab-registry.oit.duke.edu/devops/containers/ruby:2.6

build_opts = --incremental
$(shell git diff-index --quiet HEAD --)
ifeq ($(.SHELLSTATUS), 1)
	build_opts := $(build_opts) --copy
endif

build:
	docker pull $(builder_image)
	s2i build . $(builder_image) $(build_tag) $(build_opts)

test:
	./.docker/test.sh up --exit-code-from app

rubocop:
	./.docker/test.sh run app bundle exec rubocop

.PHONY: build test rubocop
