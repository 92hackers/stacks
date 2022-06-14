package state

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
	"universe.dagger.io/bash"
	"dagger.io/dagger/core"
	"github.com/h8r-dev/stacks/chain/internal/deploy/kubectl"
)

#Store: {
	namespace:  string
	kubeconfig: dagger.#Secret
	waitFor:    bool | *"true"

	src: core.#Source & {
		path: "."
	}

	manifest: core.#ReadFile & {
		input: src.output
		path:  "./default-infra-output.yaml"
	}

	run: kubectl.#Manifest & {
		"waitFor":    waitFor
		"manifest":   manifest.contents
		"namespace":  namespace
		"kubeconfig": kubeconfig
	}

	success: run.success
}

#Get: {
	image:      docker.#Image
	namespace:  string
	kubeconfig: dagger.#Secret

	targetConfigmap: "heighliner-infra-config"
	stateFile:       "/tmp/heighliner-infra-state.yaml"

	run: bash.#Run & {
		input: image
		env: {
			KUBECONFIG: kubeconfig
			NAMESPACE:  namespace
		}
		// script: contents: """
		//   kubectl get configmap \(targetConfigmap) \
		//     -n $NAMESPACE \
		//     -o yaml | yq ".data.infra" > \(stateFile)
		// """
	}

	_state: core.#ReadFile & {
		input: run.output
		path:  stateFile
	}

	state: _state.contents
}

#Update: {
	image:         docker.#Image
	namespace:     string
	kubeconfig:    dagger.#Secret
	updateContent: string

	targetConfigmap: "heighliner-infra-config"

	run: bash.#Run & {
		input: image
		env: {
			KUBECONFIG:     kubeconfig
			NAMESPACE:      namespace
			UPDATE_CONTENT: updateContent
		}
		// script: contents: """
		//   kubectl patch configmap \(targetConfigmap) \
		//     --namespace $NAMESPACE \
		//     --type merge \
		//     --patch '{"data": {"infra": $UPDATE_CONTENT}}'
		// """
	}
}
