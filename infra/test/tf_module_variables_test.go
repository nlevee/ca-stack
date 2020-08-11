package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTfModuleVariables(t *testing.T) {
	t.Parallel()

	rootDir := "../"

	workingDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "modules/variables")

	nameSuffix := fmt.Sprintf("-%s", random.UniqueId())

	azureOptions := &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"workspace":   "azure-testing",
			"name_suffix": nameSuffix,
		},
	}

	defer terraform.Destroy(t, azureOptions)
	terraform.InitAndApply(t, azureOptions)
	validateModVar(t, azureOptions, nameSuffix)
}

func validateModVar(t *testing.T, opts *terraform.Options, suffix string) {
	checkOutputs := []string{
		"azure_location",
		"azure_resource_group",
	}
	for _, outName := range checkOutputs {
		// Run `terraform output` to get the values of output variables and check they have the expected values.
		output := terraform.Output(t, opts, outName)
		assert.NotEmpty(t, output)
	}

	// check if suffix is apply
	output := terraform.Output(t, opts, "azure_resource_group")
	regex := fmt.Sprintf("%s$", suffix)
	assert.Regexp(t, regex, output, "suffix "+suffix+" is not in `azure_resource_group`")
}
