#!/bin/bash

set -e

# TODO : move to packer
# startzone
echo "Updating packages ..."
apt update
apt install -y curl jq openssl wget

for tool in cfssljson cfssl mkbundle; do
    curl -SsL https://github.com/cloudflare/cfssl/releases/download/v1.4.1/${tool}_1.4.1_linux_amd64 \
        -o /usr/local/sbin/${tool}
    chmod +x /usr/local/sbin/${tool}
done
# endzone

mkdir ~/cfssl
chmod 700 ~/cfssl
cd ~/cfssl

# auth in vault
AccessToken=$(curl -Ss -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" | jq -r '.access_token')

echo "Fetch Root Certificate from vault ..."
echo "$(curl -Ss -H "Authorization: Bearer ${AccessToken}" -X GET \
    "https://ca-stack-vm-vault.vault.azure.net/secrets/CaRootCert?api-version=7.0" | jq -r '.value' | base64 -d)" > /usr/local/share/ca-certificates/ca.pem

# update ca cert repos
update-ca-certificates

echo "Fetch Intermediate Certificate from Vault ..."
echo "$(curl -Ss -H "Authorization: Bearer ${AccessToken}" -X GET \
    "https://ca-stack-vm-vault.vault.azure.net/secrets/CaIntermediate?api-version=7.0" | jq -r .value)" > ~/cfssl/intermediate_ca.pem

# split pem
awk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "intermediate_ca." c ".pem"}' < intermediate_ca.pem
mv intermediate_ca.0.pem intermediate_ca-key.pkcs8
mv intermediate_ca.1.pem intermediate_ca.pem

# serve issuer server
cat <<EOF > server-config.json
{
  "signing": {
    "default": {
        "usages": [
          "signing",
          "digital signing",
          "key encipherment",
          "server auth"
        ],
        "expiry": "720h"
    }
  }
}
EOF

cfssl serve -config server-config.json -address 0.0.0.0 -port 8888 -ca intermediate_ca.pem -ca-key intermediate_ca-key.pkcs8 &