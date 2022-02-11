
DOCKER_HUB_ID := $(shell cat .secrets/DOCKER_HUB_ID)
DOCKER_HUB_PASSWORD := $(shell cat .secrets/DOCKER_HUB_PASSWORD)

DOMAIN             ?= gke-test.localtest.pl
REACT_APP_API_HOST ?= https://demoapp-api.gke-test.localtest.pl
REACT_APP_HOST     ?= https://demoapp.gke-test.localtest.pl
PROXY_HOST         ?= https://proxy.gke-test.localtest.pl
DEMO_APP_TAG 	   ?= dev

export DEMO_APP_TAG
export GITHUB_USER
export GITHUB_REPO
export DOCKER_HUB_ID
export DOCKER_HUB_PASSWORD
export REACT_APP_API_HOST
export REACT_APP_HOST
export PROXY_HOST
export DOMAIN

##################################################################################
#### Tests
##################################################################################

tests:
	curl -k ${REACT_APP_HOST}
	curl -k ${REACT_APP_API_HOST}/stats

helm-tests:
	curl -k ${REACT_APP_HOST}
	curl -k ${REACT_APP_API_HOST}/stats
	curl -k ${PROXY_HOST}
	curl -k ${PROXY_HOST}/stats

##################################################################################
#### Docker
##################################################################################

dlogin:
	@echo ${DOCKER_HUB_PASSWORD} | docker login -u ${DOCKER_HUB_ID} --password-stdin

docker-gen-api-requirements:
	cd api && \
	make build-api-requirements-image
	make docker-run-api-requirements

build-api-image:
	cd api && \
	make build-api-image

docker-run-api:
	cd api && \
	make docker-run-api

##################################################################################
#### Docker Compose
##################################################################################

dc-upb: 
	make dc-build
	make dc-up

dc-up:
	docker-compose up --remove-orphans

dc-down:
	docker-compose down --remove-orphans

dc-up-d:
	docker-compose up --detach --remove-orphans

dc-build:
	docker-compose build --parallel --progress auto --compress

dc-build-k8s:
	docker-compose -f docker-compose.k8s.yaml \
				   build --parallel --progress auto --compress 
	

dc-push: 
	docker-compose push

dc-push-k8s: 
	docker-compose -f docker-compose.k8s.yaml \
				   push 

dc-pushb:
	make dc-build
	make dlogin
	make dc-push

dc-pushb-k8s:
	make dc-build-k8s
	make dlogin
	make dc-push-k8s

##################################################################################
#### Kuberntes
##################################################################################

##################################################################################
#### Helm 
##################################################################################

helm-deploy-demoapp: 
	kubectl apply -f helm/demoapp/namespace.yaml
	while ! kubectl get secret -n demoapp gke-letsencrypt-cert; do sleep 1; done
	while ! kubectl get secret -n demoapp letsencrypt-ca; do sleep 1; done

	cd helm/demoapp && \
	helm upgrade --wait \
				 --timeout 15m \
				 --debug \
				 --install \
				 --render-subchart-notes \
				 --namespace demoapp \
				 --create-namespace \
				 helm-demoapp .

