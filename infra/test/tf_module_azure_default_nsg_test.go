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

	stageName := "mod_az_nsg"

	// Uncomment these when doing local testing if you need to skip any stages.
	// os.Setenv("SKIP_deploy_"+stageName+"_rg", "true")
	// os.Setenv("SKIP_deploy_"+stageName, "true")
	// os.Setenv("SKIP_validate_"+stageName, "true")
	// os.Setenv("SKIP_teardown_"+stageName, "true")

	globalDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "live/azure/global")

	workingDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "modules/azure_default_nsg")

	defer test_structure.RunTestStage(t, "teardown_"+stageName, func() {
		undeployModAzNsg(t, workingDir)
		undeployAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_"+stageName+"_rg", func() {
		configAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_"+stageName, func() {
		rgName := test_structure.LoadString(t, globalDir, "rgName")
		deployModAzNsg(t, workingDir, rgName)
	})

	test_structure.RunTestStage(t, "validate_"+stageName, func() {
		validateNsg(t, workingDir)
	})
}

func undeployModAzNsg(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}

func deployModAzNsg(t *testing.T, workingDir string, resourceGroup string) {
	nsgName := fmt.Sprintf("terratest-nsg-%s", random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"name":                nsgName,
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
		assert.NotEmpty(t, output, outName+"is empty")
	}

	// check if name is apply
	output := terraform.Output(t, terraformOptions, "nsg_name")
	assert.Equal(t, terraformOptions.Vars["name"], output, "nsg_name is not equal to -var")
}
