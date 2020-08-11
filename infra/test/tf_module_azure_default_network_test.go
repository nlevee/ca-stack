package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestTfModuleAzureDefaultNetwork(t *testing.T) {
	t.Parallel()

	rootDir := "../"

	stageName := "mod_az_network"

	globalDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "live/azure/global")

	workingDir := test_structure.CopyTerraformFolderToTemp(t, rootDir, "modules/azure_default_network")

	defer test_structure.RunTestStage(t, "teardown_"+stageName, func() {
		undeployModAzNetwork(t, workingDir)
		undeployAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_"+stageName+"_rg", func() {
		configAzGlobal(t, globalDir)
	})

	test_structure.RunTestStage(t, "deploy_"+stageName, func() {
		rgLocation := test_structure.LoadString(t, globalDir, "rgLocation")
		rgName := test_structure.LoadString(t, globalDir, "rgName")
		deployModAzNetwork(t, workingDir, rgName, rgLocation)
	})

	test_structure.RunTestStage(t, "validate_"+stageName, func() {
		validateNetwork(t, workingDir)
	})
}

func undeployModAzNetwork(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}

func deployModAzNetwork(t *testing.T, workingDir string, resourceGroup string, location string) {
	networkName := fmt.Sprintf("terratest-network-%s", random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"network_name":        networkName,
			"address_range":       "10.50.0.0/16",
			"location":            location,
			"resource_group_name": resourceGroup,
		},
	}
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}

func validateNetwork(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	output := terraform.Output(t, terraformOptions, "network_id")
	assert.NotEmpty(t, output)

	subnets := terraform.OutputList(t, terraformOptions, "subnet_ids")
	assert.Len(t, subnets, 1)

	addresses := terraform.OutputList(t, terraformOptions, "subnet_address_ranges")
	assert.Len(t, addresses, 1)
}
