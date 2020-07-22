#!/bin/bash -e

base_path=$(realpath $(dirname $0))
builder_path=$(realpath ${base_path}/../../infra/builder)

img_name=$1
[ -z "${img_name}" ] && exit 1

# load azure env
source ${base_path}/.env

# create template temporary file
tmpfile=$(mktemp /tmp/packer-script.XXXXXX)
jq --slurp '.[0] * .[1]' \
    ${builder_path}/builders/azure/builder.json \
    ${builder_path}/images/${img_name}/provisioner.json > ${tmpfile}

# validation du template
packer validate \
    -var "managed_image_name=${img_name}"\
    -var "playbook_path=${builder_path}/images/${img_name}" \
    ${tmpfile}

# execution du build
packer build \
    -var "managed_image_name=${img_name}"\
    -var "playbook_path=${builder_path}/images/${img_name}" \
    ${tmpfile}

# del template temporary file 
rm -f ${tmpfile}
