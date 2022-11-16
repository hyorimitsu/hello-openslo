include .env

run up:
	./script/app.sh run

stop down:
	./script/app.sh stop

deps:
	docker-compose -f ./tools/docker-compose-tools.yaml run --rm \
		-v "$(PWD)/api":"/go/src/github.com/hyorimitsu/hello-openslo/api" \
		-w "/go/src/github.com/hyorimitsu/hello-openslo/api" \
		go-mod

sloth-gen:
	docker-compose -f ./tools/docker-compose-tools.yaml run --rm \
		-v "$(PWD)/.openslo":"/openslo" \
		-w "/openslo" \
		sloth-gen

logs-%:
	./script/app.sh logs $*

call-api:
	./script/api-caller.sh

dashboard:
	./script/app.sh dashboard

destroy:
	./script/app.sh destroy
