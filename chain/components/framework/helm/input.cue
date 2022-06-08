package helm

import (
	"universe.dagger.io/docker"
	"github.com/h8r-dev/stacks/chain/factory/basefactory"
	"github.com/h8r-dev/stacks/chain/internal/utils/base"
)

#Input: {
	_baseImage: base.#Image & {}
	image:      _baseImage.output

	name:      string
	chartName: string
	// Helm values set
	// Format: '.image.repository = "rep" | .image.tag = "tag"'
	set?: string | *""
	// Helm starter scaffold
	starter?:               string | *""
	domain:                 basefactory.#DefaultDomain
	gitOrganization?:       string
	appName:                string
	ingressHostPath:        string | *"/"
	rewriteIngressHostPath: bool | *false
	mergeAllCharts:         bool | *false
	repositoryType:         string | *"frontend" | "backend" | "deploy"
}
