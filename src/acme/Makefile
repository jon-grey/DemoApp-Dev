
build-gcloud-acme-image:
	docker build --tag gcloud-acme:dev  . 

docker-run-gcloud-acme: build-gcloud-acme-image
	docker run \
		-it \
		--rm \
		--name gcloud-acme-dev \
		--env-file .env \
		-p 80:80 \
		-v /var/run/docker.sock:/tmp/docker.sock:ro \
		-v ../certs:/root/certs \
		gcloud-acme:dev 

