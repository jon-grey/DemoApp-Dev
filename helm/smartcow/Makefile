

helm-dry-run-install:
	helm install helm-smartcow-test-install . --dry-run --debug --namespace smartcow

helm-dry-run-upgrade:
	helm version
	helm upgrade --wait \
				 --timeout 15m \
				 --install \
				 --namespace smartcow \
				 --create-namespace \
				 --dry-run \
				 helm-smartcow-test-upgrade .

make-dry-run:
	make helm-dry-run-install
	make helm-dry-run-upgrade

helm-template:
	helm version
	mkdir -p .manifests
	helm template --namespace smartcow \
				 --create-namespace \
				 --debug \
				 helm-smartcow . \
				 > .manifests/helm-templated.yaml
