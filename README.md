# Infra

## Prérequis

Installer [pre-commit](https://pre-commit.com/)

Sur Linux :

```bash
curl https://pre-commit.com/install-local.py | python -
~/bin/pre-commit install
```

Installer [tflint](https://github.com/terraform-linters/tflint)

Sur Linux :

```bash
curl -SsL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

Installer [terraform-docs](https://github.com/terraform-docs/terraform-docs)

Sur Linux :

```bash
curl -Lo ./terraform-docs https://github.com/terraform-docs/terraform-docs/releases/download/v0.10.0-rc.1/terraform-docs-v0.10.0-rc.1-$(uname | tr '[:upper:]' '[:lower:]')-amd64
chmod +x ./terraform-docs
sudo mv ./terraform-docs /usr/local/bin/terraform-docs
```

## TODO

- terraform remote backend
- bastion to access VM
- optim firewall
- add ocsp responder
- use terratest
- add descriptions for variables/outputs
- use terradoc
- stop using custom script ext. (use cloud-init)

## Tests

Les tests d'infra sont dans `infra/test`.

Pour lancer les tests :

```bash
cd infra/test
go test
```

## Schema

```txt
VAULT <-N3- CA-AUTH

VAULT -N4-> CA-ISSUE
VAULT -N4-> USERSPACE
VAULT -N4-> PROXY

CA-ISSUE <-N5- USERSPACE
CA-ISSUE <-N5- PROXY

WEB <-N2- PROXY <-N1- USERSPACE
```

## Usage

Créé un fichier `.env` dans `workflow/azure/` sur le modele :

```bash
export ARM_CLIENT_ID=
export ARM_CLIENT_SECRET=
export ARM_SUBSCRIPTION_ID=
export ARM_TENANT_ID=
```

Build de l'environnement :

```bash
./workflow/azure/deploy-infra.sh global
```

Build des image avec packer :

```bash
./workflow/azure/build-images.sh ca-authority
./workflow/azure/build-images.sh ca-issuer
./workflow/azure/build-images.sh userspace
./workflow/azure/build-images.sh web-proxy
```

Build de l'infra :

```bash
./workflow/azure/deploy-infra.sh networks
./workflow/azure/deploy-infra.sh vault
./workflow/azure/deploy-infra.sh ca-authority
./workflow/azure/deploy-infra.sh ca-issuer
./workflow/azure/deploy-infra.sh web-proxy
./workflow/azure/deploy-infra.sh userspace
```
