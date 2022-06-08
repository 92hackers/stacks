package next

import (
	"github.com/h8r-dev/stacks/chain/internal/utils/base"
)

#Input: {
	_baseImage: base.#Image & {}
	image:      _baseImage.output

	name:       string
	typescript: bool | *true
}
