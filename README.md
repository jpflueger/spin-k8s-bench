# Benchmarks for Spin on Kubernetes

This repository contains source code, scripts, IaC and Kubernetes manifests to repeatably test Spin on Kubernetes.

## Requirements

- Helm - used to install nginx-ingress and the containerd shim for Fermyon Spin
- Kustomize - used to templatize manifests for Spin deployments
- Spin v1.5 - current version of the containerd shim (v0.9.2) supports Spin v1.5
- Azure AKS - IaC currently targets AKS but installing the charts on other containerd based Kubernetes distributions should work and contributions for additional IaC is welcomed

## Setup the AKS cluster

TODO

## Installing required Helm charts

Several helm charts are required for the purposes of the benchmarks. We currently support using the ingress-nginx chart to expose the services. The spin-containerd-shim-installer chart is used to add support for Spin to Kubernetes nodes. 

```script
# install using the Makefile
make helm-install
```

```script
# install the ingress controller manually
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
    -n kube-system  \
    --version 4.8.3 \
    --values manifests/nginx-ingress-values.yaml

# install the containerd shim for spin
helm repo add fermyon https://charts.fermyon.app
helm repo update
helm install spin fermyon/spin-containerd-shim-installer \
    --create-namespace -n spin-installer \
    --version 0.9.2 \
    --values manifests/spin-values.yaml
```

## Building docker images

The docker images for Spin functions are the target of the benchmark tests. For now these are simple "Hello, World" functions and we're looking to add more complex examples in the future. The provided Makefile has targets to help build and push the docker images. Note that you should substitute the `REPO` and `TAG` variables to target a container registry your cluster will have access to.

```script
# use the Makefile
export REPO=docker.io/<username>
export TAG=latest
make docker-build
make docker-push
```

Alternatively you can manually build the docker images yourself. Note that building the `.wasm` assembly is currently done on the host before the docker build.

```script
# manually build the Spin JavaScript function
cd src/spin-func-js
npm install
spin build
docker buildx build --platform=wasi/wasm --provenance=false docker.io/<username>/spin-func-js:latest

# manually build the Spin Python function
cd src/spin-func-py
spin build
docker buildx build --platform=wasi/wasm --provenance=false docker.io/<username>/spin-func-py:latest
```

## Deploying the Spin functions

The Spin functions are currently templatized using kustomize for simplicity. 

```script
# use the Makefile target
make apply-manifests
```

You can also run the commands manually in your terminal.

```script
# manually run kustomize
kubectl apply -k ./manifests

# alternatively view the manifests before applying them
kubectl kustomize ./manifests
```

## Summary Results

| Runtime | Language | Avg. Response Time | Min. Response Time | Max. Response Time | 90th Percentile | 95th Percentile |
| ------- | -------- | ------------------ | ------------------ | ------------------ | --------------- | --------------- |
| spin    | js       | 86.1ms             | 59.25ms            | 391.64ms           | 108.9ms         | 186.51ms        |
| spin    | py       | 91ms               | 58.74ms            | 400.75ms           | 154.36ms        | 254.73ms        |
| azfn    | js       | 88.63ms            | 58.58ms            | 376.16ms           | 118.33ms        | 217.46ms        |
| azfn    | py       | 87.83ms            | 59.19ms            | 445.16ms           | 128.87ms        | 190.21ms        |
