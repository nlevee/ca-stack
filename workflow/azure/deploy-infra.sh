#!/bin/bash

base_path=$(realpath $(dirname $0))
infra_path=$(realpath ${base_path}/../../infra/live/azure)

workflow=$1
[ -z "${workflow}" ] && exit 1

# load azure env
source ${base_path}/.env

# apply
cd ${infra_path}/${workflow}

[ ! -d ".terraform" ] \
    && terraform init -upgrade

terraform ${2:-apply}