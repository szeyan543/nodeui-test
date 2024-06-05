# Define variables with default values
DOCKER_HUB_ID ?= szeyan11
HZN_ORG_ID ?= examples

export SERVICE_NAME ?= node-ui-service
PATTERN_NAME ?= pattern-node-ui-service
DEPLOYMENT_POLICY_NAME ?= deployment-policy-node-ui
NODE_POLICY_NAME ?= node-policy-node-ui
export SERVICE_VERSION ?= 1.0.0
export SERVICE_CONTAINER := $(DOCKER_HUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION)
ARCH ?= amd64


MATCH ?= "Hello"
TIME_OUT ?= 30

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"
CONTAINER_CREDS ?=

default: build run

build:
	docker build -t $(SERVICE_CONTAINER) .

dev: stop build
	docker run -it -v `pwd`:/outside \
          --name $(SERVICE_NAME) \
          -p 8000:8000 \
          $(SERVICE_CONTAINER) /bin/bash

run: stop
	docker run -d \
          --name $(SERVICE_NAME) \
          --restart unless-stopped \
          -p 8000:8000 \
          $(SERVICE_CONTAINER)

publish-service-policy:
	hzn exchange service addpolicy -f service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)

publish-deployment-policy:
	hzn exchange deployment addpolicy -f deployment.policy.json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)

test: run
	@echo "=================="
	@echo "Testing $(SERVICE_NAME)..."
	@echo "=================="
	./serviceTest.sh $(SERVICE_NAME) $(MATCH) $(TIME_OUT) && \
		{ docker rm -f $(SERVICE_NAME) >/dev/null; \
		echo "*** Service test succeeded! ***"; } || \
		{ docker rm -f $(SERVICE_NAME) >/dev/null; \
		echo "*** Service test failed! ***"; \
		false ;}

push:
	docker push $(SERVICE_CONTAINER)

publish: publish-service publish-service-policy publish-deployment-policy

publish-service:
	@echo "=================="
	@echo "PUBLISHING SERVICE"
	@echo "=================="
	@hzn exchange service publish -O $(CONTAINER_CREDS) --json-file=service.definition.json --pull-image
	@echo ""

remove-service:
	@echo "=================="
	@echo "REMOVING SERVICE"
	@echo "=================="
	@hzn exchange service remove -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-service-policy:
	@echo "========================="
	@echo "PUBLISHING SERVICE POLICY"
	@echo "========================="
	@hzn exchange service addpolicy -f service.policy.json $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

remove-service-policy:
	@echo "======================="
	@echo "REMOVING SERVICE POLICY"
	@echo "======================="
	@hzn exchange service removepolicy -f $(HZN_ORG_ID)/$(SERVICE_NAME)_$(SERVICE_VERSION)_$(ARCH)
	@echo ""

publish-pattern:
	@ARCH=$(ARCH) \
      SERVICE_NAME="$(SERVICE_NAME)" \
      SERVICE_VERSION="$(SERVICE_VERSION)"\
      PATTERN_NAME="$(PATTERN_NAME)" \
      hzn exchange pattern publish -f pattern.json
 
publish-deployment-policy:
	@echo "============================"
	@echo "PUBLISHING DEPLOYMENT POLICY"
	@echo "============================"
	@hzn exchange deployment addpolicy -f deployment.policy.json $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""

remove-deployment-policy:
	@echo "=========================="
	@echo "REMOVING DEPLOYMENT POLICY"
	@echo "=========================="
	@hzn exchange deployment removepolicy -f $(HZN_ORG_ID)/policy-$(SERVICE_NAME)_$(SERVICE_VERSION)
	@echo ""

stop:
	@docker rm -f $(SERVICE_NAME) >/dev/null 2>&1 || :

clean:
	@docker rmi -f $(DOCKER_HUB_ID)/$(SERVICE_NAME):$(SERVICE_VERSION) >/dev/null 2>&1 || :

agent-run:
	@echo "================"
	@echo "REGISTERING NODE"
	@echo "================"
	@hzn register --policy=node.policy.json
	@watch hzn agreement list

agent-run-pattern:
	hzn register --pattern "${HZN_ORG_ID}/$(PATTERN_NAME)"


agent-stop:
	@hzn unregister -f

deploy-check:
	@hzn deploycheck all -t device -B deployment.policy.json --service-pol=service.policy.json --node-pol=node.policy.json

.PHONY: build dev run push publish-service publish-pattern test stop clean agent-run agent-stop
