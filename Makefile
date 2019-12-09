VERSION=$(shell date +%F)
IMAGE=miry/online_games_bot
BUILD_NAME=$(IMAGE):$(VERSION)
LOG_LEVEL=debug
SHELL=bash

.PHONY: run
run:
	LOG_LEVEL=${LOG_LEVEL} bundle exec ruby runner.rb selenium_chrome

.PHONY: run.headless
run.headless:
	LOG_LEVEL=${LOG_LEVEL} bundle exec ruby runner.rb

.PHONY: run.daemon
run.daemon:
	while [ true ] ; do bundle exec ruby runner.rb; echo Exited; sleep 10m; done

.PHONY: release
release: docker.build docker.push

.PHONY: docker.run
docker.run:
	docker pull ${IMAGE}:latest
	docker run -it -e LOG_LEVEL=${LOG_LEVEL} -v $$(pwd)/config:/app/config -v $$(pwd)/tmp:/app/tmp ${IMAGE}:latest

.PHONY: docker.build
docker.build:
	docker pull ${IMAGE}:latest
	docker build -t $(IMAGE):$(VERSION) -t $(IMAGE):latest .

.PHONY: docker.push
docker.push:
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

.PHONY: servers_json
servers_json:
	@bundle exec ruby -r yaml -r json -e "puts YAML.load_file('config/servers.yml').to_json"
