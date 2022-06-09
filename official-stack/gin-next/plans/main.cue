package main

import (
	"dagger.io/dagger"
	"github.com/h8r-dev/stacks/chain/factory/scaffoldfactory"
	"github.com/h8r-dev/stacks/chain/factory/scmfactory"
	"github.com/h8r-dev/stacks/chain/factory/cdfactory"
	"github.com/h8r-dev/stacks/chain/components/utils/statewriter"
	"github.com/h8r-dev/stacks/chain/components/utils/kubeconfig"
	"github.com/h8r-dev/stacks/chain/factory/basefactory"
	"github.com/h8r-dev/stacks/chain/components/dev/nocalhost"

	"github.com/h8r-dev/stacks/chain/components/framework/gin"
	"github.com/h8r-dev/stacks/chain/components/framework/next"
	"github.com/h8r-dev/stacks/chain/components/framework/helm"
	githubCI "github.com/h8r-dev/stacks/chain/components/ci/github"
)

#Setup: {
	app_domain: string
	kubeconfig: dagger.#Secret

	_domain: basefactory.#DefaultDomain & {
		application: domain: app_domain
		infra: domain:       app_domain
	}

	_kubeconfig: kubeconfig.#TransformToInternal & {
		input: kubeconfig.#Input & {
			"kubeconfig": kubeconfig
		}
	}

	output: {
		domain:     _domain
		kubeconfig: _kubeconfig
	}
}

// Stack Plan
dagger.#Plan & {
	client: {
		commands: kubeconfig: {
			name: "cat"
			args: ["\(env.KUBECONFIG)"]
			stdout: dagger.#Secret
		}
		env: {
			ORGANIZATION:    string
			GITHUB_TOKEN:    dagger.#Secret
			KUBECONFIG:      string
			APP_NAME:        string
			APP_DOMAIN:      string | *"h8r.site"
			NETWORK_TYPE:    string | *"default"
			REPO_VISIBILITY: string | *"private"
		}
		filesystem: "output.yaml": write: contents: actions.up._output.contents
	}

	actions: {
		app_name:          client.env.APP_NAME
		frontend_app_name: app_name + "-frontend"
		backend_app_name:  app_name + "-backend"
		deploy_app_name:   app_name + "-deploy"

		setup: #Setup & {
			app_domain: client.env.APP_DOMAIN
			kubeconfig: client.commands.kubeconfig.stdout
		}

		// Spin up infra components
		up_infra: {

		}

		// Spin up application
		up_app: {

		}

		_repoVisibility: client.env.REPO_VISIBILITY

		_scaffold: scaffoldfactory.#Instance & {
			input: scaffoldfactory.#Input & {
				networkType:         client.env.NETWORK_TYPE
				appName:             client.env.APP_NAME
				domain:              setup.output.app_domain
				organization:        client.env.ORGANIZATION
				personalAccessToken: client.env.GITHUB_TOKEN
				kubeconfig:          setup.output.kubeconfig.output.kubeconfig
				repository: [
					{
						name:      client.env.APP_NAME + "-frontend"
						type:      "frontend"
						framework: "next"
						ci:        "github"
						registry:  "github"
						deployTemplate: helmStarter: "helm-starter/nodejs/node"
					},
					{
						name:      client.env.APP_NAME + "-backend"
						type:      "backend"
						framework: "gin"
						ci:        "github"
						registry:  "github"
						deployTemplate: helmStarter: "helm-starter/go/gin"
						extraArgs: helmSet: """
						'.service.labels = {"h8r.io/framework": "gin"}'
						"""
					},
					{
						name:      client.env.APP_NAME + "-deploy"
						type:      "deploy"
						framework: "helm"
					},
				]
				addons: [
					{
						name: "prometheus"
					},
					{
						name: "loki"
					},
					{
						name: "nocalhost"
					},
				]
			}
		}

		_git: scmfactory.#Instance & {
			input: scmfactory.#Input & {
				provider:            "github"
				personalAccessToken: client.env.GITHUB_TOKEN
				organization:        client.env.ORGANIZATION
				repositorys:         _scaffold.output.image
				visibility:          _repoVisibility
				kubeconfig:          setup.output.kubeconfig.output.kubeconfig
			}
		}

		up: {
			_cd: cdfactory.#Instance & {
				input: cdfactory.#Input & {
					provider:    "argocd"
					repositorys: _git.output.image
					kubeconfig:  setup.output.kubeconfig.output.kubeconfig
					domain:      setup.output.app_domain
				}
			}
			_initNocalhost: nocalhost.#Instance & {
				input: nocalhost.#Input & {
					image:              _cd.output.image
					githubAccessToken:  client.env.GITHUB_TOKEN
					githubOrganization: client.env.ORGANIZATION
					kubeconfig:         setup.output.kubeconfig.output.kubeconfig
					appName:            client.env.APP_NAME
					apiServer:          setup.output.kubeconfig.output.apiServer
				}
			}
			_output: statewriter.#Output & {
				input: _cd.output
			}
		}
	}
}
