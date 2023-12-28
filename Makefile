SPIN_BUILD_ARGS = --platform=wasi/wasm --provenance=false

REPO ?= docker.io/library
TAG ?= latest

.PHONY: docker-build
docker-build: docker-build-spin docker-build-azfn

.PHONY: docker-build-spin
docker-build-spin: docker-build-spin-js docker-build-spin-py docker-build-spin-rust docker-build-spin-go

.PHONY: docker-build-spin-js
docker-build-spin-js:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-js:$(TAG) ./src/spin-func-js

.PHONY: docker-build-spin-py
docker-build-spin-py:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-py:$(TAG) ./src/spin-func-py

.PHONY: docker-build-spin-rust
docker-build-spin-rust:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-rust:$(TAG) ./src/spin-func-rust

.PHONY: docker-build-spin-go
docker-build-spin-go:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-go:$(TAG) ./src/spin-func-go

.PHONY: docker-build-azfn
docker-build-azfn: docker-build-azfn-js docker-build-azfn-py

.PHONY: docker-build-azfn-js
docker-build-azfn-js:
	docker build --platform=linux/amd64 -t $(REPO)/azfn-js:$(TAG) ./src/az-func-js

.PHONY: docker-build-azfn-py
docker-build-azfn-py:
	docker build --platform=linux/amd64 -t $(REPO)/azfn-py:$(TAG) ./src/az-func-py

.PHONY: docker-push
docker-push: docker-push-spin docker-push-azfn

.PHONY: docker-push-spin
docker-push-spin:
	docker push $(REPO)/spin-js:$(TAG)
	docker push $(REPO)/spin-py:$(TAG)
	docker push $(REPO)/spin-rust:$(TAG)
	docker push $(REPO)/spin-go:$(TAG)

.PHONY: docker-push-azfn
docker-push-azfn:
	docker push $(REPO)/azfn-js:$(TAG)
	docker push $(REPO)/azfn-py:$(TAG)

.PHONY: apply-manifests
apply-manifests:
	kubectl apply -k ./manifests

.PHONY: helm-repos-add
helm-repos-add:
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update

.PHONY: helm-install
helm-install: helm-repos-add
	helm install ingress-nginx ingress-nginx/ingress-nginx \
		-n kube-system  \
		--version 4.8.3 \
		--values manifests/nginx-ingress-values.yaml

	helm install spin-containerd-shim-installer oci://ghcr.io/fermyon/charts/spin-containerd-shim-installer \
		-n kube-system \
		--version 0.10.0 \
		--values manifests/spin-values.yaml

.PHONY: k6-run
k6-run: k6-run-spin k6-run-azfn

.PHONY: k6-run-spin
k6-run-spin: k6-run-spin-js k6-run-spin-py

.PHONY: k6-run-spin-js
k6-run-spin-js:
	./benches/run.sh spin js

.PHONY: k6-run-spin-py
k6-run-spin-py:
	./benches/run.sh spin py

.PHONY: k6-run-spin-rust
k6-run-spin-rust:
	./benches/run.sh spin rust

.PHONY: k6-run-spin-go
k6-run-spin-go:
	./benches/run.sh spin go

.PHONY: k6-run-azfn
k6-run-azfn: k6-run-azfn-js k6-run-azfn-py

.PHONY: k6-run-azfn-js
k6-run-azfn-js:
	./benches/run.sh azfn js

.PHONY: k6-run-azfn-py
k6-run-azfn-py:
	./benches/run.sh azfn py