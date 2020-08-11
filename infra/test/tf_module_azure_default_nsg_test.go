package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTfModuleAzureDefaultNsg(t *testing.T) {
	t.Parallel()

	rootDir := "../"

	globalDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "live/azure/global")

	workingDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "modules/azure_default_nsg")

	defer test_structure.RunTestStage(t, "cleanup_global", func() {
		undeployAzGlobal(t, globalDir)
	})

	defer test_structure.RunTestStage(t, "cleanup_nsg", func() {
		undeployModAzNsg(t, workingDir)
	})

	test_structure.RunTestStage(t, "deploy_global", func() {
		configAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_nsg", func() {
		rgLocation := test_structure.LoadString(t, globalDir, "rgLocation")
		rgName := test_structure.LoadString(t, globalDir, "rgName")
		deployModAzNsg(t, workingDir, rgName, rgLocation)
	})

	test_structure.RunTestStage(t, "validate", func() {
		validateNsg(t, workingDir)
	})
}

func undeployModAzNsg(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}

func deployModAzNsg(t *testing.T, workingDir string, resourceGroup string, location string) {
	nsgName := fmt.Sprintf("terratest-nsg-%s", random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"name":                nsgName,
			"location":            location,
			"resource_group_name": resourceGroup,
		},
	}
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}

func validateNsg(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	checkOutputs := []string{
		"nsg_id",
		"nsg_name",
	}

	for _, outName := range checkOutputs {
		output := terraform.Output(t, terraformOptions, outName)
		assert.NotEmpty(t, output)
	}
}
