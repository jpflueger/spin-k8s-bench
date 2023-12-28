SPIN_BUILD_ARGS = --platform=wasi/wasm --provenance=false

REPO ?= docker.io/library
TAG ?= latest

.PHONY: docker
docker: docker-spin docker-azfn

.PHONY: docker-spin
docker-spin: docker-spin-js docker-spin-py docker-spin-rust docker-spin-go

#TODO: we could parameterize this if I were better at make, right?

.PHONY: docker-spin-js
docker-spin-js:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-js:$(TAG) ./src/spin-func-js
	docker push $(REPO)/spin-js:$(TAG)
	cd manifests/overlays/spin && kustomize edit set image spin-js=$(REPO)/spin-js:$(TAG)

.PHONY: docker-spin-py
docker-spin-py:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-py:$(TAG) ./src/spin-func-py
	docker push $(REPO)/spin-py:$(TAG)
	cd manifests/overlays/spin && kustomize edit set image spin-py=$(REPO)/spin-py:$(TAG)

.PHONY: docker-spin-rust
docker-spin-rust:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-rust:$(TAG) ./src/spin-func-rust
	docker push $(REPO)/spin-rust:$(TAG)
	cd manifests/overlays/spin && kustomize edit set image spin-rust=$(REPO)/spin-rust:$(TAG)

.PHONY: docker-spin-go
docker-spin-go:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-go:$(TAG) ./src/spin-func-go
	docker push $(REPO)/spin-go:$(TAG)
	cd manifests/overlays/spin && kustomize edit set image spin-go=$(REPO)/spin-go:$(TAG)

.PHONY: docker-azfn
docker-azfn: docker-azfn-js docker-azfn-py

.PHONY: docker-azfn-js
docker-azfn-js:
	docker build --platform=linux/amd64 -t $(REPO)/azfn-js:$(TAG) ./src/az-func-js
	docker push $(REPO)/azfn-js:$(TAG)
	cd manifests/overlays/azfn && kustomize edit set image azfn-js=$(REPO)/azfn-js:$(TAG)

.PHONY: docker-azfn-py
docker-azfn-py:
	docker build --platform=linux/amd64 -t $(REPO)/azfn-py:$(TAG) ./src/az-func-py
	docker push $(REPO)/azfn-py:$(TAG)
	cd manifests/overlays/azfn && kustomize edit set image azfn-py=$(REPO)/azfn-py:$(TAG)

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