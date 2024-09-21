# ############################################################# #
# Change variables below for your own                           #
# ############################################################# #

# Project repo address and repo namespace
# The project module name will be: [repo_addr/][repo_name/]project_name
# Comment it out or leave it blank to unset a variable
repo_addr := github.com
repo_name := go-hao

# Project name
# Comment it out or leave it blank for default value (Root folder name of the project)
project_name :=

# Name for main executable of the project
# Comment it out or leave it blank for default value (main)
main_name :=

# Proxy address for GOPROXY
# Do not add https:// or http:// in front of the address
# Comment it out or leave it blank for default value (proxy.golang.org)
proxy_addr := goproxy.cn


# ############################################################# #
# Do not touch codes below                                      #
# ############################################################# #

# Auto set variables
ifndef project_name
project_name := $(notdir $(shell pwd))
endif

ifndef main_name
main_name := main
endif

module_name := $(project_name)
ifdef repo_name
repo_name_slash := $(addsuffix /,$(repo_name))
module_name := $(addsuffix $(module_name),$(repo_name_slash))
endif

ifdef repo_addr
repo_addr_slash := $(addsuffix /,$(repo_addr))
module_name := $(addsuffix $(module_name),$(repo_addr_slash))
endif

goproxy_env := https://proxy.golang.org,direct
ifdef proxy_addr
goproxy_suffix := ,direct
goproxy_env := $(addsuffix $(goproxy_suffix),https://$(proxy_addr))
endif

for_cmd_dir := cmd
for_cmd_sub_dirs := $(shell ls ./$(for_cmd_dir) 2>/dev/null)
for_cmd_dirs := $(foreach dir,$(for_cmd_sub_dirs),$(for_cmd_dir)/$(dir))
for_cmd_dirs_with_slash := $(foreach dir,$(for_cmd_sub_dirs),$(for_cmd_dir)/$(dir)/)
for_cmd_tars := $(for_cmd_dirs) $(for_cmd_dirs_with_slash)

for_docker_dir := docker
for_docker_sub_dirs := $(shell ls ./$(for_docker_dir) 2>/dev/null)
for_docker_operations := up down ps logs
ifdef for_docker_sub_dirs
for_docker_dirs := $(foreach dir,$(for_docker_sub_dirs),$(for_docker_dir)/$(dir))
for_docker_tars := $(foreach dir,$(for_docker_sub_dirs),$(foreach operation,$(for_docker_operations),$(for_docker_dir)/$(dir)/$(operation)))
for_docker_tars_up := $(foreach dir,$(for_docker_sub_dirs),$(for_docker_dir)/$(dir)/up)
for_docker_tars_down := $(foreach dir,$(for_docker_sub_dirs),$(for_docker_dir)/$(dir)/down)
for_docker_tars_ps := $(foreach dir,$(for_docker_sub_dirs),$(for_docker_dir)/$(dir)/ps)
for_docker_tars_logs := $(foreach dir,$(for_docker_sub_dirs),$(for_docker_dir)/$(dir)/logs)
endif

# Targets and commands
.DEFAULT_GOAL := help

## help: show help
.PHONY: help
help:
	@echo Usage\: make [option]
	@echo Options\:
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' |  sed -e 's/^/ /'

## go.mod: initialize the project
go.mod:
	go mod init $(module_name)
	@if [ ! -f ./cmd/$(main_name)/main.go ]; then \
		mkdir -p ./cmd/$(main_name); \
		touch ./cmd/$(main_name)/main.go; \
		echo "package main\n" >> ./cmd/$(main_name)/main.go; \
		echo "import \"fmt\"\n" >> ./cmd/$(main_name)/main.go; \
		echo "func main() {" >> ./cmd/$(main_name)/main.go; \
		echo "\tfmt.Println(\"Hello go!\")" >> ./cmd/$(main_name)/main.go; \
		echo "}" >> ./cmd/$(main_name)/main.go; \
	fi

## set: set go environment variables - GO111MODULE(on) and GOPROXY
.PHONY: set
set:
	go env -w GO111MODULE=on
	go env -w GOPROXY=$(goproxy_env)

## run: run the project
.PHONY: run
run: build
	./bin/$(main_name)

## build: build the project
.PHONY: build
build: tidy
	go build -v -o ./bin/$(main_name) ./cmd/$(main_name)

## tidy: tidy modfile and format code
.PHONY: tidy
tidy:
	go mod tidy -v
	go fmt ./...

## clean: clean build content
.PHONY: clean
clean:
	rm -rf ./bin

## cmd/<dir>: build the project defined in ./cmd/<dir>
.PHONY: $(for_cmd_tars)
$(for_cmd_tars): tidy
	@for i in $(for_cmd_sub_dirs); do \
		if [[ $@ == */$$i ]] || [[ $@ == */$$i/ ]]; then \
			go build -v -o ./bin/$$i ./$@; \
		fi; \
	done

## all: build all defined in ./cmd
.PHONY: all
all: $(for_cmd_tars)
	@echo $@ > /dev/null

## swag: swag init command
.PHONY: swag
swag:
	swag init -g ./cmd/$(main_name)/main.go

# ############################################################# #
# Docker services                                               #
# ############################################################# #

## docker/<dir>/<op>: manage the service in ./docker/<dir>
## all/<op>: shortcut to manage all services
## : <op> options - up      start the service
## :                down    stop the service
## :                ps      show status of the service
## :                logs    show logs of the service
.PHONY: $(for_docker_tars)
$(for_docker_tars):
	@echo ---- $@
	@for i in $(for_docker_dirs); do \
		if [[ $@ == $$i/* ]]; then \
			cd $$i; \
		fi; \
	done; \
	if [[ $@ == */up ]]; then \
		docker compose up -d; \
	elif [[ $@ == */down ]]; then \
		docker compose down; \
	elif [[ $@ == */ps ]]; then \
		docker compose ps -a; \
	elif [[ $@ == */logs ]]; then \
		docker compose logs; \
	fi

.PHONY: all/up
all/up: $(for_docker_tars_up)
	@echo $@ > /dev/null

.PHONY: all/down
all/down: $(for_docker_tars_down)
	@echo $@ > /dev/null

.PHONY: all/ps
all/ps: $(for_docker_tars_ps)
	@echo $@ > /dev/null

.PHONY: all/logs
all/logs: $(for_docker_tars_logs)
	@echo $@ > /dev/null
