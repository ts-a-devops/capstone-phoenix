# Cost

This echoes the Docker lesson's "why one server" thread — except now the answer to "is the
extra cost worth it?" is yours to argue.

## Monthly itemized cost
| Item | Spec | Qty | $/mo |
|---|---|---:|---:|
| control-plane VM | small cloud VM (e.g. AWS t3.medium or equivalent) | 1 | $25 |
| worker VMs | small cloud VM (e.g. AWS t3.small or equivalent) | 2 | $40 |
| load balancer / public IP | managed LB or elastic IP | 1 | $10 |
| block storage (PVC) | 20GB persistent volume | 1 | $2 |
| object storage (state, backups) | S3 / object store | 1 | $2 |
| DNS / domain | public domain registration | 1 | $1 |
| **Total** | | | **$80** |

> Replace these values with your actual cloud provider pricing and instance sizes.

## Compared to the single-server Compose+Portainer deploy
- That stack cost roughly: $15–$25 per month for one small VM and a single public IP.
- This cluster costs: $80 per month for a control-plane VM, 2 workers, a public endpoint, storage, and state/backups.
- **What the extra spend buys:** fault isolation across nodes, cluster-managed persistent storage, GitOps deployment through Argo CD, HTTPS with cert-manager, and the ability to safely reschedule pods.

## How I'd halve this
- Use smaller worker instances or spot/preemptible worker nodes for the application tier.
- Keep the control-plane on one modest VM (k3s does not require a large master node for this scale).
- Reuse a single public IP or ingress endpoint instead of a managed load balancer when the provider allows it.
- Reduce PostgreSQL storage to the minimum needed for the demo dataset.
