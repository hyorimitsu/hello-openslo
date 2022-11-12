include .env

run up:
	./script/app.sh run

stop down:
	./script/app.sh stop

logs-%:
	./script/app.sh logs $*

dashboard:
	./script/app.sh dashboard

destroy:
	./script/app.sh destroy
