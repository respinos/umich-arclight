SHELL = /bin/bash

build_tag ?= dul-arclight
builder_image ?= gitlab-registry.oit.duke.edu/devops/containers/ruby:2.6-main

build_opts = --assemble-user 0 --incremental -p never

$(shell git diff-index --quiet HEAD --)
ifeq ($(.SHELLSTATUS), 1)
	build_opts := $(build_opts) --copy
endif

.PHONY : build
build:
	docker pull $(builder_image)
	s2i build file://$(shell pwd) $(builder_image) $(build_tag) $(build_opts)

.PHONY : test
test:
	./.docker/test-default.sh

.PHONY : test-accessibility
test-accessibility:
	./.docker/test-accessibility.sh

.PHONY : rubocop
rubocop:
	docker run --rm -v "$(shell pwd):/opt/app-root" $(build_tag) \
		bundle exec rubocop
