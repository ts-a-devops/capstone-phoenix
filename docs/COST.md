# Cost — Phoenix TaskApp on OCI

## Monthly itemized cost
| Item | Spec | Qty | $/mo |
|---|---|---:|---:|
| control-plane VM | A1.Flex, 1 OCPU / 6 GB (Always Free) | 1 | $0 |
| worker VMs | A1.Flex, 1 OCPU / 9 GB (Always Free) | 2 | $0 |
| load balancer / public IP | k3s klipper servicelb on node IPs (no OCI LB) | — | $0 |
| block storage | ~150 GB boot + 1 GB PVC (≤ 200 GB Always Free) | — | $0 |
| object storage (tfstate) | < 1 GB (≤ 20 GB Always Free) | — | $0 |
| DNS / domain | registrar, ~$12/yr (not an OCI charge) | 1 | ~$1 |
| **Total** | | | **~$1/mo** ($0 infra + domain) |

The whole 3-node cluster sits inside OCI **Always Free** (4 OCPU / 24 GB Ampere A1, 200 GB block,
20 GB object storage). Pay As You Go is enabled only to escape A1 capacity contention — free-tier
shapes still bill **$0**. The single real cost is the domain.

## Compared to the single-server Compose + Portainer deploy
- That stack: one small VM — also **$0** on an OCI Always Free micro/A1 instance.
- This cluster: **$0** as well.
- **What the extra capability buys:** because Always Free covers three nodes, HA, autoscaling,
  zero-downtime rollouts, and multi-node self-healing come at **no extra dollar cost** — unusual,
  and worth stating plainly. The real price paid is **operational complexity**: Terraform + Ansible
  + k3s + GitOps to learn and run, versus one `docker compose up`. **When it's NOT worth it:** a
  low-traffic side project with no uptime SLA — the single box is simpler for the same $0.

## How I'd halve this
It's already ~$0 — you can't halve zero. The honest version: **if this ran on a paid provider**,
the `infra-aws/` mirror (3× `t4g.medium` + 150 GB gp3) would cost roughly **$80–100/mo**
(illustrative). I'd halve *that* by:
- **spot/preemptible workers** (~70% off) for the stateless tiers;
- collapsing to **2 nodes** (schedulable server + 1 worker) — still real multi-node;
- **ARM (Graviton/Ampere) over x86**, smaller instance types;
- a **shared ingress** instead of a managed load balancer.

On OCI free, the only line item left is the domain (~$12/yr); a free subdomain service would zero
even that, but the brief requires a real domain + public cert, so I keep it.
