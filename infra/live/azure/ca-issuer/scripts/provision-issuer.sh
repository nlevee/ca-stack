#!/bin/bash

set -e

[ ! -d ~/cfssl ] \
    && mkdir ~/cfssl \
    && chmod 700 ~/cfssl

cd ~/cfssl

# auth in vault
AccessToken=$(curl -Ssf -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" | jq -r '.access_token')

echo "Fetch Root Certificate from vault ..."
curl -Ssf -H "Authorization: Bearer ${AccessToken}" -X GET \
    "https://ca-stack-vm-vault.vault.azure.net/secrets/CaRootCert2?api-version=7.0" \
    | jq -r '.value' | base64 -d > /usr/local/share/ca-certificates/ca.crt

# update ca cert repos
update-ca-certificates

# fetch intermediate bundle certificate
echo "Fetch Intermediate Certificate from Vault ..."
curl -Ssf -H "Authorization: Bearer ${AccessToken}" -X GET \
    "https://ca-stack-issuer-vault.vault.azure.net/secrets/CaIntermediate2?api-version=7.0" \
    | jq -r .value > ~/cfssl/intermediate_ca.pem

# split pem
awk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "intermediate_ca." c ".pem"}' < intermediate_ca.pem
if [ ! -f "intermediate_ca.0.pem" ] || [ ! -f "intermediate_ca.1.pem" ]; then
    exit 3
fi 
mv intermediate_ca.0.pem intermediate_ca-key.pkcs8
chmod 700 intermediate_ca-key.pkcs8
mv intermediate_ca.1.pem intermediate_ca.pem

# serve issuer server
cat <<EOF > server-config.json
{
  "signing":{
    "default":{
      "expiry":"720h"
    },
    "profiles":{
      "intermediate":{
        "expiry":"720h",
        "usages":[
          "signing",
          "digital signature",
          "key encipherment",
          "cert sign",
          "crl sign",
          "server auth",
          "client auth"
        ],
        "ca_constraint":{
          "is_ca":true,
          "max_path_len":0,
          "max_path_len_zero":true
        }
      },
      "peer":{
        "usages":[
          "signing",
          "digital signature",
          "key encipherment",
          "client auth",
          "server auth"
        ],
        "expiry":"720h"
      },
      "server":{
        "usages":[
          "signing",
          "digital signing",
          "key encipherment",
          "server auth"
        ],
        "expiry":"720h"
      },
      "client":{
        "usages":[
          "signing",
          "digital signature",
          "key encipherment",
          "client auth"
        ],
        "expiry":"720h"
      }
    }
  }
}
EOF

# create system service to start issuer server
[ ! -d "/etc/systemd/system" ] \
    && mkdir -p /etc/systemd/system

cat <<EOF > /etc/systemd/system/cfssl-server.service
[Unit]
Description=CFSSL PKI Certificate Issuer
After=network.target

[Service]
User=root
ExecStart=/usr/local/sbin/cfssl serve \
    -config server-config.json \
    -address 0.0.0.0 -port 8888 \
    -ca intermediate_ca.pem \
    -ca-key intermediate_ca-key.pkcs8
Restart=on-failure
Type=simple
WorkingDirectory=/root/cfssl

[Install]
WantedBy=multi-user.target
EOF

# enable at boot and start cfssl server
systemctl daemon-reload
systemctl enable cfssl-server
systemctl start cfssl-server

exit 0