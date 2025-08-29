//go:build !validation

package test

import (
	"testing"

	tofu "github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTofuValidation(t *testing.T) {
	t.Parallel()

	tofuOptions := &tofu.Options{
		TerraformDir: "../",
		NoColor:      true,
	}

	tofu.Init(t, tofuOptions)
	tofu.Validate(t, tofuOptions)
	tofu.Plan(t, tofuOptions)

	t.Log("Tofu configuration is valid")
}
