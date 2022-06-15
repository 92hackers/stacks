package argocd

import (
	"github.com/h8r-dev/stacks/chain/internal/deploy/kubectl"
	"github.com/h8r-dev/stacks/chain/internal/cd/argocd"
	"github.com/h8r-dev/stacks/chain/internal/network/ingress"

	// Update state
	"github.com/h8r-dev/stacks/chain/components/infra/state"
)

#Instance: {
	input: #Input
	do:    kubectl.#Apply & {
		url:        input.url
		namespace:  input.namespace
		kubeconfig: input.kubeconfig
		waitFor:    input.waitFor
	}
	// patch argocd http
	_patch: argocd.#Patch & {
		namespace:  input.namespace
		kubeconfig: input.kubeconfig
		"input":    input.image
		waitFor:    do.success
	}
	// set ingress for argocd
	ingressVersion: ingress.#GetIngressVersion & {
		image:      input.image
		kubeconfig: input.kubeconfig
	}
	ingressYaml: ingress.#Ingress & {
		name:               "argocd"
		namespace:          input.namespace
		hostName:           input.domain.infra.argocd
		path:               "/"
		backendServiceName: "argocd-server"
		"ingressVersion":   ingressVersion.content
	}
	applyIngressYaml: kubectl.#Manifest & {
		kubeconfig: input.kubeconfig
		manifest:   ingressYaml.manifestStream
		namespace:  input.namespace
	}

	getState: state.#Get & {
		image:      input.image
		namespace:  input.namespace
		kubeconfig: input.kubeconfig
		key:        "argocd"
	}

	updateInfraState: state.#Update & {
		image:         input.image
		namespace:     input.namespace
		kubeconfig:    input.kubeconfig
		updateContent: ""
	}
	output: #Output & {
		image:   _patch.output
		success: _patch.success
	}
}

#UpdateState: {
	username: string
	password: string
}
