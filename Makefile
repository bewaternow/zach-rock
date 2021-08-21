.PHONY:  release-server release-client contributors
export GOPROXY=https://goproxy.cn
export CGO_ENABLED=0
#===================================================================================
BUILD_ID        := $(shell git rev-parse HEAD)
BUILD_ID_SHORT  := $(shell git rev-parse --short HEAD)
BUILD_TIME      := $(shell date "+%F %T")
BUILD_AUTHOR    := $(shell git config --get user.name)
BUILD_EMAIL    	:= $(shell git config --get user.email)
BUILD_INFO		:= $(shell git log --oneline --no-merges | grep $(BUILD_ID_SHORT))
#===================================================================================
BUILD_TAGS				:= release
TARGET_BIN 				:= bin

fmt:
	go fmt client/*
	go fmt server/*

clean:
	rm bin/*

rock-server:
	go build -tags '$(BUILD_TAGS)' -o ${TARGET_BIN}/rock zach-rock/server

rock-client:
	go build -tags '$(BUILD_TAGS)' -o ${TARGET_BIN}/roll zach-rock/client

rock-all: fmt rock-server rock-client

contributors:
	echo "zach-rock 的参与者, 无论贡献大小:\n" > CONTRIBUTORS
	git log --raw | grep "^Author: " | sort | uniq | cut -d ' ' -f2- | sed 's/^/- /' | cut -d '<' -f1 >> CONTRIBUTORS