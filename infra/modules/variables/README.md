# Variables Module

Module use to match a workspace to env variables

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name\_suffix | Suffix to add to all name outputs | `string` | `""` | no |
| workspace | Workspace name to get vars | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| azure\_location | Location (West Europe, ...) in azure |
| azure\_resource\_group | Resource group in azure |
