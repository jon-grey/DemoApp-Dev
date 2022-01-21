
build-api-image:
	docker build --tag api:dev  . 

build-api-requirements-image:
	docker build --tag api-requirements:dev --file Dockerfile.requirements .
	

docker-run-api: build-api-image
	docker run -it --rm --name api-dev -p 8080:5000 --env-file .env api:dev  

docker-run-api-requirements:
	docker run -it --rm --name api-requirements-dev --env-file .env \
		-v ${PWD}/requirements:/tmp/requirements \
		api-requirements:dev 

venv-run-api:
	bash .scripts/venv-run-app.sh

gen-requirements:
	bash .scripts/venv-gen-requirements.sh

