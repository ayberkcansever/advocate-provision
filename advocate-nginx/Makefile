build:
	docker build -t advocate-nginx .

tag:
	docker tag advocate-nginx:latest ${DOCKER_REGISTRY}/advocate-nginx

push:
	docker push ${DOCKER_REGISTRY}/advocate-nginx

release: build tag push

run: build
	docker run -it -p 8080:80 --env-file .env --rm --name advocate-nginx --link advocate --link advocate-bridge --volumes-from advocate advocate-nginx

shell:
	docker exec -it advocate-nginx /bin/sh
