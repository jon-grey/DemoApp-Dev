
build-frontend-image:
	docker build --tag frontend:dev  . 

docker-run-frontend: build-frontend-image
	docker run --name frontend-dev -it --rm -p 80:80 --env-file .env frontend:dev 

