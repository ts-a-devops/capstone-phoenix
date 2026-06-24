Ansible scaffolds for provisioning the k3s cluster

This directory contains a minimal, idempotent set of roles and a playbook to
install a single k3s control plane and join workers. Use variables from
`inventory.ini` or pass via `--extra-vars`.

Usage (example):

```bash
# install roles (if using galaxy requirements later)
# run the playbook (replace inventory and ssh key as needed)
ansible-playbook -i inventory.ini site.yml --user ubuntu --private-key ~/.ssh/my-key.pem
```

Roles included:
- `base-hardening`: create deploy user, configure SSH, enable UFW
- `k3s-server`: install k3s server and write join token to `/tmp/k3s_token`
- `k3s-agent`: install k3s agent and join server using token

These are scaffolds — review and adjust for your environment before running.
