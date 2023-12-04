SPIN_BUILD_ARGS = --platform=wasi/wasm --provenance=false

REPO ?= docker.io/library
TAG ?= latest

.PHONY: docker-build
docker-build: docker-build-spin

.PHONY: docker-build-spin
docker-build-spin: docker-build-spin-js docker-build-spin-py

.PHONY: docker-build-spin-js
docker-build-spin-js:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-func-js:$(TAG) ./src/spin-func-js

.PHONY: docker-build-spin-py
docker-build-spin-py:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-func-py:$(TAG) ./src/spin-func-py

.PHONY: docker-push
docker-push: docker-push-spin

.PHONY: docker-push-spin
docker-push-spin:
	docker push $(REPO)/spin-func-js:$(TAG)
	docker push $(REPO)/spin-func-py:$(TAG)

.PHONY: build-manifests
build-manifests:
	kustomize build manifests --output manifests.yaml

.PHONY: apply-manifests
apply-manifests: build-manifests
	kubectl apply -f manifests.yaml

.PHONY: helm-repos-add
helm-repos-add:
	helm repo add fermyon https://charts.fermyon.app
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update

.PHONY: helm-install
helm-install: helm-repos-add
	helm install ingress-nginx ingress-nginx/ingress-nginx \
		-n kube-system  \
		--version 4.8.3 \
		--values manifests/nginx-ingress-values.yaml

	helm install spin fermyon/spin-containerd-shim-installer \
		--create-namespace -n spin-installer \
		--version 0.9.2 \
		--values manifests/spin-values.yaml
