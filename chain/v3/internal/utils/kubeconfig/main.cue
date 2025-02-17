package kubeconfig

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
	"universe.dagger.io/bash"
	"github.com/h8r-dev/stacks/chain/v3/internal/base"
)

// TransformToInternal transforms the given kubeconfig to internal cluster address
#TransformToInternal: {
	input: kubeconfig: dagger.#Secret

	output: {
		kubeconfig: dagger.#Secret
		apiServer:  string
	}

	_baseImage: base.#Image

	_kubeconfig: input.kubeconfig

	_sh: core.#Source & {
		path: "."
		include: ["run.sh"]
	}

	_run: bash.#Run & {
		always: true
		input:  _baseImage.output
		mounts: kubeconfig: {
			dest:     "/kubeconfig"
			contents: _kubeconfig
			mask:     0o022
		}
		script: {
			directory: _sh.output
			filename:  "run.sh"
		}
		export: files: "/api_server": string
	}

	_getSecret: core.#NewSecret & {
		input: _run.output.rootfs
		path:  "/result"
	}

	output: {
		kubeconfig: _getSecret.output
		apiServer:  _run.export.files."/api_server"
	}
}
