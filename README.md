# Infra

## TODO

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
