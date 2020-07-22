# Infra

## TODO

- use var in provision script for vault and CA names
- terraform remote backend
- bastion to access VM
- use multiple vault for certificate&key
- add firewall.s
- wip userspace
- find a proxy

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

Build des image avec packer :

```bash
./workflow/azure/build-images.sh ca-authority
./workflow/azure/build-images.sh ca-issuer
./workflow/azure/build-images.sh userspace
```

Build de l'infra :

```bash
./workflow/azure/deploy-infra.sh networks
./workflow/azure/deploy-infra.sh vault
./workflow/azure/deploy-infra.sh ca-authority
./workflow/azure/deploy-infra.sh ca-issuer
./workflow/azure/deploy-infra.sh userspace
```
