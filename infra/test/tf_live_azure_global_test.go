package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTfLiveAzureGlobal(t *testing.T) {
	t.Parallel()

	rootDir := "../"

	stageName := "live_az_global"

	globalDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "live/azure/global")

	defer test_structure.RunTestStage(t, "cleanup_"+stageName, func() {
		undeployAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_"+stageName, func() {
		deployAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "validate_"+stageName, func() {
		validateAzGlobal(t, globalDir)
	})
}

func undeployAzGlobal(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}

func deployAzGlobal(t *testing.T, workingDir string) {
	uniqueID := random.UniqueId()

	terraformOptions := &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"workspace":   "azure-testing",
			"name_suffix": fmt.Sprintf("-%s", uniqueID),
		},
	}
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}

func validateAzGlobal(t *testing.T, workingDir string) {

	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	checkOutputs := []string{
		"resource_group_location",
		"resource_group_name",
	}

	for _, outName := range checkOutputs {
		output := terraform.Output(t, terraformOptions, outName)
		assert.NotEmpty(t, output)
	}
}
