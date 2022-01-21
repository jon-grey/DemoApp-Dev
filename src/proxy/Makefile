
build-proxy-image:
	docker build --tag proxy:dev  . 

docker-run-proxy: build-proxy-image
	docker run \
		-it \
		--rm \
		--name proxy-dev \
		--env-file .env \
		-p 80:80 \
		-v /var/run/docker.sock:/tmp/docker.sock:ro \
		-v certs:/etc/nginx/certs \
		proxy:dev 

