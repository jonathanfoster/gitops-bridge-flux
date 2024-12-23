SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

CLUSTER_NAME = gitops-bridge-flux

.PHONY: all
all: help

##@ Available Commands:

.PHONY: cluster-create
cluster-create: ## Create local kind cluster
	kind create cluster --name=${CLUSTER_NAME} --config=hack/kind.yaml

.PHONY: kind-create
cluster-delete: ## Delete local kind cluster
	kind delete cluster --name=${CLUSTER_NAME}

.PHONY: flux-bootstrap
flux-bootstrap: ## Bootstrap Flux
	helm install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator -n flux-system --create-namespace

.PHONY: flux-bootstrap-local
flux-bootstrap-local: flux-bootstrap ## Bootstrap Flux local cluster
	kubectl apply -f cluster/flux-system/flux.yaml

.PHONY: flux-reconcile
flux-reconcile: ## Reconcile Flux source
	flux reconcile source git flux-system
	flux reconcile kustomization infra-controllers
	flux reconcile kustomization infra-configs
	flux reconcile kustomization monitoring
	flux reconcile kustomization apps-nats

.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: install-toolchain
install-toolchain: ## Install toolchain
	brew install fluxcd/tap/flux
	brew install helm
	brew install kind
	brew install kubeconform
	brew install kustomize
	brew tap nats-io/nats-tools
	brew install nats-io/nats-tools/nats
	brew install yamllint
	brew install yq

.PHONY: kind-create-cluster
kind-create-cluster: ## Create kind cluster
	kind create cluster --name=${CLUSTER_NAME} --config=hack/kind.yaml

.PHONY: kind-delete-cluster
kind-delete-cluster: ## Delete kind cluster
	kind delete cluster --name=${CLUSTER_NAME}

.PHONY: lint
lint: lint-kustomize lint-yaml ## Lint all files

.PHONY: lint-kustomize
lint-kustomize: ## Lint kustomize files
	./hack/validate.sh

.PHONY: lint-yaml
lint-yaml: ## Lint YAML files
	yamllint .

.PHONY: pre-commit
pre-commit: lint ## Run pre-commit checks
