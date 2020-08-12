package test

import (
	"fmt"
	"net"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

// TestTfModuleAzureDefaultNetwork start testing Azure Default Network terraform module
func TestTfModuleAzureDefaultNetwork(t *testing.T) {
	t.Parallel()

	rootDir := "../"

	stageName := "mod_az_network"

	// Uncomment these when doing local testing if you need to skip any stages.
	// os.Setenv("SKIP_deploy_"+stageName+"_rg", "true")
	// os.Setenv("SKIP_deploy_"+stageName, "true")
	// os.Setenv("SKIP_validate_"+stageName, "true")
	// os.Setenv("SKIP_teardown_"+stageName, "true")

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
		rgName := test_structure.LoadString(t, globalDir, "rgName")

		deployModAzNetwork(t, workingDir, rgName)
	})

	test_structure.RunTestStage(t, "validate_"+stageName, func() {
		validateNetwork(t, workingDir)
	})
}

// undeployModAzNetwork destroy terraform module deployment
func undeployModAzNetwork(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}

// deployModAzNetwork init and apply terraform module
func deployModAzNetwork(t *testing.T, workingDir string, resourceGroup string) {
	networkName := fmt.Sprintf("terratest-network-%s", random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: workingDir,
		Vars: map[string]interface{}{
			"network_name":        networkName,
			"address_range":       "10.50.0.0/16",
			"resource_group_name": resourceGroup,
			"subnet_names": []string{
				"subnet0",
				"subnet1",
			},
			"service_endpoints": []string{"Microsoft.KeyVault"},
		},
	}
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}

// validateNetwork check output from terraform module
func validateNetwork(t *testing.T, workingDir string) {
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	subnetNames := terraformOptions.Vars["subnet_names"].([]interface{})

	output := terraform.Output(t, terraformOptions, "network_id")
	assert.NotEmpty(t, output, "network_id is empty")

	subnets := terraform.OutputList(t, terraformOptions, "subnet_ids")
	assert.Len(t, subnets, len(subnetNames), "`subnet_ids` length is invalid")

	addresses := terraform.OutputList(t, terraformOptions, "subnet_address_ranges")
	assert.Len(t, addresses, len(subnetNames), "`subnet_address_ranges` length is invalid")

	// check addresses
	for _, cidr := range addresses {
		_, _, err := net.ParseCIDR(cidr)
		assert.Nil(t, err, "net.ParseCIDR")
	}
}
