package vue

import (
	"universe.dagger.io/docker"
	"universe.dagger.io/bash"
	"dagger.io/dagger/core"
)

#Instance: {
	input: #Input

	src: core.#Source & {
		path: "."
	}

	_build: bash.#Run & {
		"input": input.image
		workdir: "/scaffold"
		env: APP_NAME: input.name
		script: {
			directory: src.output
			filename:  "copy.sh"
		}
	}
	_file: core.#Source & {
		path: "template"
	}
	do: docker.#Copy & {
		"input":  _build.output
		contents: _file.output
		dest:     "/scaffold/\(input.name)"
	}

	output: #Output & {
		image: do.output
	}
}
