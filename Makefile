SPIN_BUILD_ARGS = --platform=wasi/wasm --provenance=false
AZFN_BUILD_ARGS = --platform=linux/arm64,linux/amd64

REPO ?= docker.io/library
TAG ?= latest

.PHONY: docker-build
docker-build: docker-build-spin docker-build-az

.PHONY: docker-build-azfn
docker-build-azfn: docker-build-azfn-js docker-build-azfn-py

.PHONY: docker-build-azfn-cs
docker-build-azfn-cs:
	docker buildx build $(AZFN_BUILD_ARGS) -t $(REPO)/az-func-cs:$(TAG) ./src/az-func-cs

.PHONY: docker-build-azfn-js
docker-build-azfn-js:
	docker buildx build $(AZFN_BUILD_ARGS) -t $(REPO)/az-func-js:$(TAG) ./src/az-func-js

.PHONY: docker-build-azfn-py
docker-build-azfn-py:
	docker buildx build $(AZFN_BUILD_ARGS) -t $(REPO)/az-func-py:$(TAG) ./src/az-func-py

.PHONY: docker-build-spin
docker-build-spin: docker-build-spin-js docker-build-spin-py

.PHONY: docker-build-spin-cs
docker-build-spin-cs:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-func-cs:$(TAG) ./src/spin-func-cs

.PHONY: docker-build-spin-js
docker-build-spin-js:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-func-js:$(TAG) ./src/spin-func-js

.PHONY: docker-build-spin-py
docker-build-spin-py:
	docker buildx build $(SPIN_BUILD_ARGS) -t $(REPO)/spin-func-py:$(TAG) ./src/spin-func-py

.PHONY: docker-push
docker-push: docker-push-azfn docker-push-spin

.PHONY: docker-push-azfn
docker-push-azfn:
	# docker push $(REPO)/az-func-cs:$(TAG)
	docker push $(REPO)/az-func-js:$(TAG)
	docker push $(REPO)/az-func-py:$(TAG)

.PHONY: docker-push-spin
docker-push-spin:
	# docker push $(REPO)/spin-func-cs:$(TAG)
	docker push $(REPO)/spin-func-js:$(TAG)
	docker push $(REPO)/spin-func-py:$(TAG)

.PHONY: build-manifests
build-manifests:
	kustomize build manifests --enable-helm --output manifests.yaml

.PHONY: apply-manifests
apply-manifests: build-manifests
	kubectl apply -f manifests.yaml
