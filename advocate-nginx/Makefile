build:
	docker build --build-arg ADVOCATE_SERVER=${ADVOCATE_SERVER} -t advocate-nginx_${BUILD_ENV} .

tag:
	docker tag advocate-nginx_${BUILD_ENV}:latest ${DOCKER_REGISTRY}/advocate-nginx_${BUILD_ENV}

push:
	docker push ${DOCKER_REGISTRY}/advocate-nginx_${BUILD_ENV}

release: build tag push

run: build
	docker run -it -p 8080:80 --env-file .env --rm --name advocate-nginx --link advocate --link advocate-bridge --volumes-from advocate advocate-nginx_${BUILD_ENV}

shell:
	docker exec -it advocate-nginx /bin/sh
