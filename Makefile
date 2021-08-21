.PHONY:  server client all contributors test-server test-client test-all
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
SOURCE_DIR				:= zach-rock/ready
TARGET_BIN 				:= bin
SERVER_EXE_NAME			:= rock
CLIENT_EXE_NAME			:= roll

fmt:
	go fmt client/*
	go fmt server/*

clean:
	rm bin/*

server:
	go build -tags '$(BUILD_TAGS)' -o ${TARGET_BIN}/${SERVER_EXE_NAME} ${SOURCE_DIR}/server

client:
	go build -tags '$(BUILD_TAGS)' -o ${TARGET_BIN}/${CLIENT_EXE_NAME} ${SOURCE_DIR}/client

all: server client

test-server:
	${TARGET_BIN}/${SERVER_EXE_NAME} -httpAddr=:80 -domain="zach-rock.com" -log="./bin/log.txt"

test-client:
	${TARGET_BIN}/${CLIENT_EXE_NAME} -config=${TARGET_BIN}/config.yml start web ssh

test-all: test-server test-client

contributors:
	echo "zach-rock 的参与者, 无论贡献大小:\n" > CONTRIBUTORS
	git log --raw | grep "^Author: " | sort | uniq | cut -d ' ' -f2- | sed 's/^/- /' | cut -d '<' -f1 >> CONTRIBUTORS