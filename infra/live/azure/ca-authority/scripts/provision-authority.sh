#!/bin/bash

set -e

[ ! -d "~/cfssl" ] \
    && mkdir ~/cfssl \
    && chmod 700 ~/cfssl

cd ~/cfssl
cat <<EOF > ca-config.json
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "intermediate_ca": {
        "usages": [
            "signing",
            "digital signature",
            "key encipherment",
            "cert sign",
            "crl sign",
            "server auth",
            "client auth"
        ],
        "expiry": "720h",
        "ca_constraint": {
            "is_ca": true,
            "max_path_len": 0, 
            "max_path_len_zero": true
        }
      },
      "peer": {
        "usages": [
            "signing",
            "digital signature",
            "key encipherment", 
            "client auth",
            "server auth"
        ],
        "expiry": "720h"
      },
      "server": {
        "usages": [
          "signing",
          "digital signing",
          "key encipherment",
          "server auth"
        ],
        "expiry": "720h"
      },
      "client": {
        "usages": [
          "signing",
          "digital signature",
          "key encipherment", 
          "client auth"
        ],
        "expiry": "720h"
      }
    }
  }
}
EOF

cat <<EOF > ca-csr.json
{
    "CN": "MyOrg Root CA",
    "key": {
        "algo": "rsa",
        "size": 4096
    },
    "names": [
        {
            "C": "FR",
            "L": "Paris",
            "O": "MyOrg",
            "OU": "IT"
        }
    ]
}
EOF

echo "Generate Root certificate"
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

echo "Convert key to pkcs8"
openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in ca-key.pem -out ca-key.pkcs8

[ ! -d "~/cfssl/intermediate" ] \
    && mkdir ~/cfssl/intermediate 
    
cd ~/cfssl/intermediate
cat <<EOF > intermediate.json
{
  "CN": "MyOrg Intermediate CA",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C":  "FR",
      "L":  "Paris",
      "O":  "MyOrg",
      "OU": "IT"
    }
  ]
}
EOF

# generate CSR
cfssl genkey intermediate.json | cfssljson -bare intermediate_ca

# generate & sign Certificate
cfssl sign -ca ~/cfssl/ca.pem \
  -ca-key ~/cfssl/ca-key.pem \
  -config ~/cfssl/ca-config.json \
  -profile intermediate_ca intermediate_ca.csr | cfssljson -bare intermediate_ca

# convert key to pkcs8
openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in intermediate_ca-key.pem -out intermediate_ca-key.pkcs8

# make pem to import in azure vault
cat intermediate_ca-key.pkcs8 intermediate_ca.pem > intermediate.pem

# auth in vault
AccessToken=$(curl -Ssf -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" | jq -r '.access_token')

cd ~

echo "Import Root Certificate in Vault ..."
cat <<EOF > cert.json
{
"value": "$(base64 ~/cfssl/ca.pem)"
}
EOF
curl -fSs -H "Authorization: Bearer ${AccessToken}" -H "Content-type: application/json" -X PUT \
    "https://ca-stack-vm-vault.vault.azure.net/secrets/CaRootCert2?api-version=7.0" \
    -d @cert.json
rm -f cert.json

echo "Import Intermediate Certificate in Vault ..."
cat <<EOF > cert.json
{
  "value": "$(base64 ~/cfssl/intermediate/intermediate.pem)"
}
EOF
curl -fSs -H "Authorization: Bearer ${AccessToken}" -H "Content-type: application/json" -X POST \
    "https://ca-stack-issuer-vault.vault.azure.net/certificates/CaIntermediate2/import?api-version=7.0" \
    -d @cert.json
rm -f intermediate.json

# shutdown VM
shutdown &

exit 0