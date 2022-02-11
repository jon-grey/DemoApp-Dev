

helm-dry-run-install:
	helm install helm-demoapp-test-install . --dry-run --debug --namespace demoapp

helm-dry-run-upgrade:
	helm version
	helm upgrade --wait \
				 --timeout 15m \
				 --install \
				 --namespace demoapp \
				 --create-namespace \
				 --dry-run \
				 helm-demoapp-test-upgrade .

make-dry-run:
	make helm-dry-run-install
	make helm-dry-run-upgrade

helm-template:
	helm version
	mkdir -p .manifests
	helm template --namespace demoapp \
				 --create-namespace \
				 --debug \
				 helm-demoapp . \
				 > .manifests/helm-templated.yaml
