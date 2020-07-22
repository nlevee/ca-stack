#!/bin/bash

set -e

# auth in vault
AccessToken=$(curl -Ss -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" | jq -r '.access_token')

echo "Fetch Root Certificate from vault ..."
echo "$(curl -Ss -H "Authorization: Bearer ${AccessToken}" -X GET \
    "https://ca-stack-vm-vault.vault.azure.net/secrets/CaRootCert?api-version=7.0" | jq -r '.value' | base64 -d)" > /usr/local/share/ca-certificates/ca.pem

# update ca cert repos
update-ca-certificates

# create a new client certificate

# 