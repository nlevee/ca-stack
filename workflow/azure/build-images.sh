#!/bin/bash -e

base_path=$(realpath $(dirname $0))
builder_path=$(realpath ${base_path}/../../infra/builder)

img_name=$1
[ -z "${img_name}" ] && exit 1
shift

# load azure env
source ${base_path}/.env

# fetch resource group name from terraform global output
resource_group_name=$("${base_path}/deploy-infra.sh" global output resource_group_name)
[ -z "${resource_group_name}" ] && { 
        echo "resource group name is empty"
        exit 1
    }

# create template temporary file
tmpfile=$(mktemp /tmp/packer-script.XXXXXX)
jq --slurp '.[0] * .[1]' \
    ${builder_path}/builders/azure/builder.json \
    ${builder_path}/images/${img_name}/provisioner.json > ${tmpfile}

# validation du template
echo "Validating packer config ..."
packer validate \
    -var "managed_image_name=${img_name}"\
    -var "resource_group_name=${resource_group_name}"\
    -var "playbook_path=${builder_path}/images/${img_name}" \
    ${tmpfile} $@

# execution du build
echo "Start packer build ..."
packer build \
    -var "managed_image_name=${img_name}"\
    -var "resource_group_name=${resource_group_name}"\
    -var "playbook_path=${builder_path}/images/${img_name}" \
    ${tmpfile} $@

# del template temporary file 
rm -f ${tmpfile}
