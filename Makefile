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

.PHONY : clean
clean:
	./.docker/dev.sh down
	./.docker/test.sh down
	PROJECT_SUFFIX=test-a11y ./.docker/test.sh down
	rm -rf ./tmp/*
	rm -f ./log/*.log
	docker volume ls -q --filter 'name=dul-arclight-' | xargs docker volume rm

.PHONY : test
test:
	./.docker/test.sh \
		-f docker-compose.test-default.yml \
		up \
		--exit-code-from app

.PHONY : accessibility
accessibility:
	PROJECT_SUFFIX=test-a11y \
		./.docker/test.sh \
		-f docker-compose.test-a11y.yml \
		up \
		--exit-code-from app

.PHONY : rubocop
rubocop:
	docker run --rm -v "$(shell pwd):/opt/app-root" $(build_tag) \
		bundle exec rubocop
