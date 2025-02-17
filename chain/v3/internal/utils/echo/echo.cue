package echo

import (
	"universe.dagger.io/bash"
	"dagger.io/dagger/core"
	"github.com/h8r-dev/stacks/chain/v3/internal/base"
)

#Run: {
	msg: _

	_sh: core.#Source & {
		path: "."
		include: ["echo.sh"]
	}

	_deps: base.#Image

	bash.#Run & {
		input:  _deps.output
		always: true
		env: MESSAGE: msg
		script: {
			directory: _sh.output
			filename:  "echo.sh"
		}
	}
}
