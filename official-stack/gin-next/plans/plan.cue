package stack

import (
	// Stack engine
	"github.com/h8r-dev/stacks/chain/components/engine/baseEngine"

	// Infra
	// "github.com/h8r-dev/stacks/chain/components/dev/nocalhost"
	// "github.com/h8r-dev/stacks/chain/components/cd/argocd" // Argocd relys on CI
	// githubCI "github.com/h8r-dev/stacks/chain/components/ci/github"
	// "github.com/h8r-dev/stacks/chain/components/addons/prometheus"
	// "github.com/h8r-dev/stacks/chain/components/addons/loki"
	// "github.com/h8r-dev/stacks/chain/components/addons/sealedSecrets"
	// githubSCM "github.com/h8r-dev/stacks/chain/components/scm/github"
	// githubPackage "github.com/h8r-dev/stacks/chain/components/registry/github"

	// Third-party infra component
	// "github.com/92hackers/certManager"

	// Official Application
	"github.com/h8r-dev/stacks/chain/components/framework/gin"
	"github.com/h8r-dev/stacks/chain/components/framework/next"
	"github.com/h8r-dev/stacks/chain/components/framework/helm"

	// Third-party application component
	"github.com/92hackers/koa"
)

#Stack: {
	kubeconfig_path: string

	apps: [
		{
			name:   string
			domain: string
			framework: {
				// Store it's state in a configmap
				backend: gin.#Instance & {}

				// Store it's state into a configmap
				frontend: next.#Instance & {}
			}
		},
		{
			name:   string
			domain: string
			framework: {
				// Store it's state in a configmap
				backend: gin.#Instance & {}

				// Store it's state into a configmap
				frontend: next.#Instance & {}
			}
		},
	]

	ci: component: githubCI.#Instance & {}

	// Git repo provider
	gitRepo: {
		component: githubSCM.#Instance & {}
	}

	cd: {
		component: argocd.#Instance & {}
		deploy: {
			method: 'helm' // helm or k8s manifest
			repo:   helm.#Instance & {}
		}
	}

	monitor: component: prometheus.#instance & {}

	imageRegistry: component: githubPackage.#Instance & {}

	logging: {

	}
}

baseEngine.#Engine & {
	stack: #Stack
}
