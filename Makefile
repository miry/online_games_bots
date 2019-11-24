VERSION=$(shell date +%F)
IMAGE=miry/online_games_bot
BUILD_NAME=$(IMAGE):$(VERSION)
LOG_LEVEL="DEBUG"
SHELL=zsh

run:
	while true ; do ; LOG_LEVEL=${LOG_LEVEL} bundle exec ruby runner.rb selenium_chrome ; sleep 5m ; done

release: docker.build docker.push

docker.run: docker.build
	docker run -it -e LOG_LEVEL=${LOG_LEVEL} -v $(pwd)/config:/app/config -v $(pwd)/tmp:/app/tmp ${IMAGE}:${VERSION}

docker.build:
	docker build -t $(IMAGE):$(VERSION) -t $(IMAGE):latest .

docker.push:
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

.PHONY: servers_json
servers_json:
	@bundle exec ruby -r yaml -r json -e "puts YAML.load_file('config/servers.yml').to_json"
