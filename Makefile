.DEFAULT_GOAL := help

#### Constant variables
# use -count=1 to disable cache and -p=1 to stream output live
# EXPORTVAR := export APPSODY_STACKS=incubator/nodejs-express,incubator/java-microprofile
# EXPORTVAR := export APPSODY_STACKS=incubator/terrence
GO_TEST_COMMAND := go test -v -count=1 -p=1
# Set a default VERSION only if it is not already set
VERSION ?= 0.0.0
COMMAND := appsody
BUILD_PATH := $(PWD)/build
PACKAGE_PATH := $(PWD)/package
GO_PATH := $(shell go env GOPATH)
GOLANGCI_LINT_BINARY := $(GO_PATH)/bin/golangci-lint
GOLANGCI_LINT_VERSION := v1.16.0
BINARY_EXT_linux :=
BINARY_EXT_darwin :=
BINARY_EXT_windows := .exe
DOCKER_IMAGE_RPM := alectolytic/rpmbuilder
DOCKER_IMAGE_DEB := appsody/debian-builder
CONTROLLER_BASE_URL := https://github.com/${GH_ORG}/controller/releases/download/0.2.1
CLI_BASE_URL := https://github.com/${GH_ORG}/appsody/archive/0.3.0.zip
CLI_ZIP := 0.3.0.zip

#### Dynamic variables. These change depending on the target name.
# Gets the current os from the target name, e.g. the 'build-linux' target will result in os = 'linux'
# CAUTION: All targets that use these variables must have the OS after the first '-' in their name.
#          For example, these are all good: build-linux, tar-darwin, tar-darwin-new
os = $(word 2,$(subst -, ,$@))
build_name = $(COMMAND)-$(VERSION)-$(os)-amd64
build_binary = $(build_name)$(BINARY_EXT_$(os))
package_binary = $(COMMAND)$(BINARY_EXT_$(os))

.PHONY: all
all: lint test package ## Run lint, test, build, and package

.PHONY: get-cli
get-cli: ## get cli code from repo
	#wget https://github.com/appsody/appsody/archive/0.2.5.zip
	#unzip 0.2.5.zip

	# this way was working as of 7/24/19...
	# go env GOPATH
	# mkdir -p /home/travis/gopath/src/github.com/appsody
	# cd /home/travis/gopath/src/github.com/appsody && git clone https://github.com/tnixa/appsody.git
	# cd /home/travis/gopath/src/github.com/appsody/appsody && git checkout testsandbox
	# cd /home/travis/gopath/src/github.com/appsody/appsody && make install-controller
	# cd /home/travis/gopath/src/github.com/appsody/appsody/functest && go test

	# try new way with vendor path...
	
	go env GOPATH
	mkdir -p vendor/github.com/appsody
	#wget ${CLI_BASE_URL}
	#unzip ${CLI_ZIP}

	# use clone vs wget until the code gets into a release
	cd vendor/github.com/appsody && git clone https://github.com/appsody/appsody.git
	#cd vendor/github.com/appsody && git clone https://github.com/tnixa/appsody.git
	#cd vendor/github.com/appsody/appsody && git checkout testsandbox

	cd vendor/github.com/appsody/appsody && make install-controller
	#unzip 0.2.5.zip -d vendor/github.com/appsody
	#mv vendor/github.com/appsody/appsody-0.2.5 vendor/github.com/appsody/appsody
	#$(EXPORTVAR) && cd vendor/github.com/appsody/appsody/functest && go test -v -count=1 -p=1 -run TestParser
	#go test -v -count=1 -p=1 ./vendor/github.com/appsody/appsody/functest -run TestParser

.PHONY: stack-tests
stack-tests: ## Run the all the automated tests
	#$(GO_TEST_COMMAND) ./...  #pass in parameter for which stack to test
	#$(EXPORTVAR) && cd vendor/github.com/appsody/appsody/functest && $(GO_TEST_COMMAND) -timeout 12h -run TestRunSimple
	cd vendor/github.com/appsody/appsody/functest && $(GO_TEST_COMMAND) -timeout 12h -run TestRunSimple
	cd vendor/github.com/appsody/appsody/functest && $(GO_TEST_COMMAND) -timeout 12h -run TestBuildSimple

.PHONY: lint
lint:  ## Run the static code analyzers
# Configure the linter here. Helpful commands include `golangci-lint linters` and `golangci-lint run -h`
# Set exclude-use-default to true if this becomes to noisy.
	echo "lint not implemented yet"

# Auto documented help from http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## Prints this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
