# Infra

## Schema

```txt
CA-AUTH -N3-> VAULT

VAULT <-N4- USERSPACE
VAULT <-N4- PROXY

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
