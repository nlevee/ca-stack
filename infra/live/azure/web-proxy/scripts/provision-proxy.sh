#!/bin/bash

set -e

# auth in vault
AccessToken=$(curl -Ssf -H "Metadata: true" "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" | jq -r '.access_token')

echo "Fetch Root Certificate from vault ..."
curl -Ssf -H "Authorization: Bearer ${AccessToken}" -X GET \
    "https://ca-stack-vm-vault.vault.azure.net/secrets/CaRootCert2?api-version=7.0" \
    | jq -r '.value' | base64 -d > /usr/local/share/ca-certificates/ca.crt

# update ca cert repos
update-ca-certificates

# fetch intermediate certificate
curl -Ssf -H "Authorization: Bearer ${AccessToken}" -X GET \
    "https://ca-stack-issuer-vault.vault.azure.net/certificates/CaIntermediate2?api-version=7.0" \
    | jq -r '.cer' | base64 -d > /tmp/intermediate_ca.cer

# convert cer certificate to pem
openssl x509 -inform DER -in /tmp/intermediate_ca.cer -out ~/intermediate_ca.pem

[ ! -d ~/.mitmproxy ] \
    && mkdir ~/.mitmproxy

cd ~/.mitmproxy

touch mitmproxy_csr.json
cat <<EOF > mitmproxy_csr.json
{
  "CN": "MyOrg web-proxy",
  "hosts": [
    ""
  ],
  "key": {
    "algo": "rsa",
    "size": 4096
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

touch remote_config.json
cat <<EOF > remote_config.json
{
  "signing": {
    "default": {
      "remote": "ca-issuer"
    }
  },
  "remotes": {
    "ca-issuer": "caissuervm:8888"
  }
}
EOF

# generate certificate for mitmproxy
cfssl gencert -config remote_config.json -profile intermediate mitmproxy_csr.json | cfssljson -bare mitmproxy

# config mitmproxy ca repos
mv mitmproxy.pem mitmproxy-ca-cert.pem
mv mitmproxy-key.pem mitmproxy-ca-key.pem

[ -f mitmproxy-ca.pem ] && rm -f mitmproxy-ca.pem
touch mitmproxy-ca.pem
cat mitmproxy-ca-key.pem >> mitmproxy-ca.pem
cat mitmproxy-ca-cert.pem >> mitmproxy-ca.pem
cat ~/intermediate_ca.pem >> mitmproxy-ca.pem
ln -sf mitmproxy-ca-cert.pem mitmproxy-ca-cert.cer

openssl pkcs12 \
    -export -out mitmproxy-ca-cert.p12 \
    -inkey mitmproxy-ca-key.pem \
    -in mitmproxy-ca-cert.pem \
    -password pass:

# create system service to start issuer server
[ ! -d "/etc/systemd/system" ] \
    && mkdir -p /etc/systemd/system

cat <<EOF > /etc/systemd/system/mitmproxy.service
[Unit]
Description=Mitmproxy server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/mitmdump
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

# enable at boot and start cfssl server
systemctl daemon-reload
systemctl enable mitmproxy
systemctl start mitmproxy

exit 0