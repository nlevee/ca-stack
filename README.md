# Infra

## TODO

- terraform remote backend
- bastion to access VM
- provision ca-authority images
- provision ca-issuer images
- use packed image for vm

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

## Steps

### Configure Hosting

### Create Networks

### Create Bastion

### Create Vault

### Build images

### Create CA-authority

- Create root CA
- Use root CA
- Put root CA to vault

### Create Proxy

- Fetch root CA from vault
- Create instance certificate with CA-auth
- Fetch instance certificate from vault
- Configure Proxy with instance certificate

### Create Userspace

- Fetch root CA from vault
- Create instance certificate with CA-auth
- Fetch instance certificate from vault
- Configure Proxy usage
