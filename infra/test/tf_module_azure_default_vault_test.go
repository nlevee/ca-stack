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

	globalDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "live/azure/global")

	workingDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "modules/azure_default_vault")

	defer test_structure.RunTestStage(t, "cleanup_global", func() {
		undeployAzGlobal(t, globalDir)
	})

	defer test_structure.RunTestStage(t, "cleanup_vault", func() {
		undeployModAzVault(t, workingDir)
	})

	test_structure.RunTestStage(t, "deploy_global", func() {
		configAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_vault", func() {
		rgLocation := test_structure.LoadString(t, globalDir, "rgLocation")
		rgName := test_structure.LoadString(t, globalDir, "rgName")
		deployModAzVault(t, workingDir, rgName, rgLocation)
	})

	test_structure.RunTestStage(t, "validate", func() {
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
	uniqueID := random.UniqueId()

	vaultName := fmt.Sprintf("terratest-vault-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"vault_name":          vaultName,
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
	}

	for _, outName := range checkOutputs {
		output := terraform.Output(t, terraformOptions, outName)
		assert.NotEmpty(t, output)
	}
}
