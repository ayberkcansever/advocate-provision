pull:
	docker-compose -f docker-compose.yml pull

run:
	# docker-compose -f docker-compose.yml run --rm --name advocate --service-ports proxy # all dependencies are started
	docker-compose -f docker-compose.yml up

start:
	docker-compose -f docker-compose.yml start

stop:
	docker-compose -f docker-compose.yml stop

deploy:
	docker stack deploy
