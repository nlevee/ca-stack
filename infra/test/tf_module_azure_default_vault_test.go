package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTfModuleAzureDefaultVault(t *testing.T) {
	t.Parallel()

	rootDir := "../"

	stageName := "mod_az_vault"

	globalDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "live/azure/global")

	workingDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "modules/azure_default_vault")

	defer test_structure.RunTestStage(t, "teardown_"+stageName, func() {
		undeployModAzVault(t, workingDir)
		undeployAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_"+stageName+"_rg", func() {
		configAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_"+stageName, func() {
		rgLocation := test_structure.LoadString(t, globalDir, "rgLocation")
		rgName := test_structure.LoadString(t, globalDir, "rgName")
		deployModAzVault(t, workingDir, rgName, rgLocation)
	})

	test_structure.RunTestStage(t, "validate_"+stageName, func() {
		validateVault(t, workingDir)
	})
}

func configAzGlobal(t *testing.T, workingDir string) {
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

	rgLocation := terraform.Output(t, terraformOptions, "resource_group_location")
	test_structure.SaveString(t, workingDir, "rgLocation", rgLocation)

	rgName := terraform.Output(t, terraformOptions, "resource_group_name")
	test_structure.SaveString(t, workingDir, "rgName", rgName)
}

func undeployModAzVault(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}

func deployModAzVault(t *testing.T, workingDir string, resourceGroup string, location string) {
	terraformOptions := &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"vault_name":          "terratest-vault",
			"location":            location,
			"resource_group_name": resourceGroup,
		},
	}
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}

func validateVault(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	checkOutputs := []string{
		"vault_id",
		"vault_uri",
		"vault_name",
	}

	for _, outName := range checkOutputs {
		output := terraform.Output(t, terraformOptions, outName)
		assert.NotEmpty(t, output)
	}
}
