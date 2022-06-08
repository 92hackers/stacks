package gin

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
	"github.com/h8r-dev/stacks/chain/internal/utils/base"
)

#Input: {
	_baseImage: base.#Image & {}
	image:      _baseImage.output

	name:       string
	kubeconfig: dagger.#Secret
}
