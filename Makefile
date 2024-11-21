SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

CLUSTER_NAME = gitops-bridge-flux

.PHONY: all
all:

.PHONY: cluster-create
cluster-create:
	kind create cluster --name=${CLUSTER_NAME} --config=hack/kind.yaml

.PHONY: kind-create
cluster-delete:
	kind delete cluster --name=${CLUSTER_NAME}

.PHONY: flux-bootstrap
flux-bootstrap:
	flux bootstrap github \
		--token-auth \
		--owner=jonathanfoster \
		--repository=gitops-bridge-flux \
		--branch=main \
		--path=clusters/local \
		--personal

.PHONY: flux-reconcile
flux-reconcile:
	flux reconcile source git flux-system


.PHONY: install-toolchain
install-toolchain:
	brew install fluxcd/tap/flux
	brew install helm
	brew install kind
	brew install kubeconform
	brew install kustomize
	brew install yq

.PHONY: lint
lint:
	./hack/validate.sh
