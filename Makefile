
GITHUB_USER := jon-grey
GITHUB_REPO := SmartCow-DevOps
DOCKER_HUB_ID := $(shell cat .secrets/DOCKER_HUB_ID)
DOCKER_HUB_PASSWORD := $(shell cat .secrets/DOCKER_HUB_PASSWORD)
export GITHUB_USER
export GITHUB_REPO
export DOCKER_HUB_ID
export DOCKER_HUB_PASSWORD

flux-install:
	curl -s https://fluxcd.io/install.sh | sudo bash

flux-bootstrap:
	flux bootstrap github   --owner=${GITHUB_USER}   --repository=${GITHUB_REPO}   --branch=master   --path=./clusters/my-cluster   --personal

##################################################################################
#### Tests
##################################################################################

tests:
	curl -k https://frontend.gke-test.localtest.pl
	curl -k https://api.gke-test.localtest.pl/stats

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

create-cluster-minikube:
	minikube start --driver=docker
	make create-cluster-minikube-post

create-cluster-minikube-post:
	minikube addons enable ingress
	make helm-deploy-kubed
	make helm-deploy-cert-manager
	make restore-cert-manager
	make helm-deploy-cert-manager-resources
	make helm-deploy-smartcow

delete-cluster-kindnes:
	kind delete cluster --name kind-smartcow

create-cluster-kindnes:
	kind create cluster --name kind-smartcow \
		--config manifests/kind-cluster.yaml
	make create-cluster-kindnes-post

create-cluster-kindnes-post:
	make setup-ingress
	make setup-dns
	make helm-deploy-kubed
	make helm-deploy-cert-manager
	make restore-cert-manager
	make helm-deploy-cert-manager-resources
	make helm-deploy-smartcow

setup-ingress:
	# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/kind/deploy.yaml
	kubectl apply -f manifests/kind-ingress-nginx-controller-v0.46.0.yaml
	kubectl --namespace ingress-nginx rollout status --timeout 15m deployment/ingress-nginx-controller

setup-dns: 
	kubectl apply -f manifests/custom-dns.yaml
	kubectl -n kube-system rollout restart deployment/coredns
	kubectl -n kube-system rollout status --timeout 5m deployment/coredns

restore-cert-manager:
	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager
	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager-cainjector
	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager-webhook

	kubectl apply -f .backups/cert-manager-backup_issuers.yaml || true
	kubectl apply -f .backups/cert-manager-backup_certs_secrets.yaml || true


##################################################################################
#### Helm 
##################################################################################


helm-deploy-smartcow: 
	kubectl apply -f helm/smartcow/namespace.yaml
	while ! kubectl get secret -n smartcow gke-letsencrypt-cert; do sleep 1; done
	while ! kubectl get secret -n smartcow letsencrypt-ca; do sleep 1; done

	cd helm/smartcow && \
	helm upgrade --wait \
				 --timeout 15m \
				 --debug \
				 --install \
				 --render-subchart-notes \
				 --namespace smartcow \
				 --create-namespace \
				 helm-smartcow .

helm-deploy-kubed: helm-init-kubed
	cd helm/kubed && \
	helm upgrade --wait \
				 --timeout 15m \
				 --debug \
				 --install \
				 --render-subchart-notes \
				 --namespace kube-system \
				 --create-namespace \
				 helm-kubed .

helm-deploy-cert-manager: helm-init-cert-manager
	kubectl apply -f helm/cert-manager/templates/namespace.yaml

	cd helm/cert-manager && \
	helm upgrade --wait \
				 --timeout 15m \
				 --install \
				 --render-subchart-notes \
				 --namespace cert-manager \
				 --create-namespace \
				 --debug \
				 helm-cert-manager .

	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager
	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager-cainjector
	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager-webhook

helm-deploy-cert-manager-resources:  
	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager
	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager-cainjector
	kubectl rollout status  -n cert-manager deployment.apps/helm-cert-manager-webhook

	cd helm/cert-manager-resources && \
	while ! helm upgrade --wait \
				 --timeout 15m \
				 --debug \
				 --install \
				 --render-subchart-notes \
				 --namespace cert-manager \
				 --create-namespace \
				 helm-cert-manager-resources . ; do sleep 1; done

helm-init-kubed:
	cd helm/kubed && \
	helm dep update --skip-refresh

helm-init-cert-manager:
	cd helm/cert-manager && \
	helm dep update --skip-refresh