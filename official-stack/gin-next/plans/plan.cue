package plan

import (
	// Stack engine
	"github.com/h8r-dev/stacks/chain/components/engine/baseEngine"

	// Infra
	"github.com/h8r-dev/stacks/chain/components/dev/nocalhost"
	"github.com/h8r-dev/stacks/chain/components/cd/argocd" // Argocd relys on CI
	githubCI "github.com/h8r-dev/stacks/chain/components/ci/github"
	"github.com/h8r-dev/stacks/chain/components/addons/prometheus"
	"github.com/h8r-dev/stacks/chain/components/addons/loki"
	"github.com/h8r-dev/stacks/chain/components/addons/sealedSecrets"
	githubSCM "github.com/h8r-dev/stacks/chain/components/scm/github"

	// Third-party infra component
	"github.com/92hackers/certManager"

	// Application
	"github.com/h8r-dev/stacks/chain/components/framework/gin"
	"github.com/h8r-dev/stacks/chain/components/framework/next"
	"github.com/h8r-dev/stacks/chain/components/framework/helm"

	// Third-party application component
	"github.com/92hackers/koa"
)

#Plan: {
	app_name:        string
	app_domain:      string
	kubeconfig_path: string

	sourceCode: {
		// Store it's state in a configmap
		backend: gin.#Instance & {}

		// Store it's state into a configmap
		frontend: next.#Instance & {}

		deploy: helm.#Instance & {}
	}

	ci: component: githubCI.#Instance & {}

	// Git repo provider
	scm: {
		component: githubSCM.#Instance & {}
	}

	cd: component: argocd.#Instance & {}

	monitor: component: prometheus.#Instance & {}

	imageRegistry: {

	}

	logging: {

	}
}

baseEngine.#Engine & {
	plan: #Plan
}
