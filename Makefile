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

#===================================================================================
DOCKER_APP_NAME				:=	zach-rock-server
DOCKER_IMAGE_TAG			:=	$(shell git rev-parse HEAD)
DOCKER_REPOSTORY			:=	zach-rock/$(DOCKER_APP_NAME)
DEPLOY_ADDR					:=	root@127.0.0.1
DEPLOY_PORT					:=	22
DRPLOY_DOCKER				:=	docker
DRPLOY_DOCKER_COMPOSE		:=	docker-compose
DEPLOY_DOCKER_FILE			:=	Dockerfile

.PHONY:  deploy-prepare deploy-server

deploy-prepare:
	ssh-copy-id -i ~/.ssh/id_rsa.pub -p $(DEPLOY_PORT) $(DEPLOY_ADDR)

deploy-prod: 
	GOOS=linux GOARCH=amd64 make server 
	ssh -p $(DEPLOY_PORT) $(DEPLOY_ADDR) "mkdir -p /opt/$(DOCKER_APP_NAME)"
	scp -P $(DEPLOY_PORT) ./${DEPLOY_DOCKER_FILE} $(DEPLOY_ADDR):/opt/$(DOCKER_APP_NAME)/Dockerfile
	scp -P $(DEPLOY_PORT) ./$(TARGET_BIN)/rock $(DEPLOY_ADDR):/opt/$(DOCKER_APP_NAME)/rock
	ssh -p $(DEPLOY_PORT) $(DEPLOY_ADDR) "cd /opt/$(DOCKER_APP_NAME) && docker build -t $(DOCKER_REPOSTORY):latest -t $(DOCKER_REPOSTORY):$(DOCKER_IMAGE_TAG) ."
	scp -P $(DEPLOY_PORT) ./docker-compose.yml $(DEPLOY_ADDR):/opt/$(DOCKER_APP_NAME)/docker-compose.yml
	ssh -p $(DEPLOY_PORT) $(DEPLOY_ADDR) "cd  /opt/$(DOCKER_APP_NAME) && $(DRPLOY_DOCKER_COMPOSE) down"
	ssh -p $(DEPLOY_PORT) $(DEPLOY_ADDR) "cd  /opt/$(DOCKER_APP_NAME) && $(DRPLOY_DOCKER_COMPOSE) up -d"
