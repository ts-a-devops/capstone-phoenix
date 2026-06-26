# Architecture — Phoenix TaskApp on OCI k3s

## 1. Topology

```
                          Internet
                             │  DNS A: taskapp.<domain> ──▶ node public IP
                             ▼
                    ┌──────────────────┐  OCI NSG: 80/443 world · 22/6443 operator-only
                    │  ingress-nginx    │  (klipper servicelb binds 80/443 on node IPs)
                    │  TLS terminated   │◀── cert-manager + Let's Encrypt (HTTP-01)
                    └────────┬──────────┘
              path /         │          path /api
        ┌──────────────┐     │     ┌──────────────┐
        │  frontend    │◀────┴────▶│   backend    │   2 replicas each, spread across nodes
        │  Service :80 │           │ Service :8000│
        └──────┬───────┘           └──────┬───────┘
               ▼                          ▼
        frontend Pods               backend Pods ──▶ ┌────────────────┐
        (node A, node B)            (node A, node B)  │ postgres (STS) │ PVC (local-path)
                                                      │  Service :5432 │ on one node
                                                      └────────────────┘

  Nodes:  phoenix-server (k3s control-plane, schedulable) + phoenix-worker-1/2 (agents)
  GitOps: Argo CD (argocd ns) reconciles ingress-nginx, cert-manager, taskapp from this repo
```

## 2. Node & network
- **Nodes:** 1 k3s server (1 OCPU / 6 GB) + 2 agents (1 OCPU / 9 GB) = the full 4-OCPU / 24 GB
  Always Free Ampere A1 allowance, all in `eu-paris-1` (single-AD region).
- **Network:** VCN `10.0.0.0/16`, one public subnet `10.0.1.0/24`, internet gateway, default route.
- **Firewall (OCI NSG, the edge):** `80`/`443` from the world; `22`/`6443` from the operator IP
  only; `6443`/`8472-udp`/`10250` intra-VCN for k3s. **`6443` is never `0.0.0.0/0`** — enforced by
  the NSG *and* a Terraform variable validation. Host iptables (OCI's default REJECT) are removed
  by the Ansible hardening role so k3s networking works; the NSG is the real firewall.

## 3. Request flow
DNS resolves `taskapp.<domain>` to a node's public IP. ingress-nginx (exposed on `:443` via k3s
klipper servicelb) terminates TLS with the cert-manager-issued Let's Encrypt cert, then routes by
path on one host: `/` → `taskapp-frontend:80`, `/api` → `taskapp-backend:8000` (same-origin, so no
CORS). The backend reads/writes `taskapp-postgres:5432` (headless Service → StatefulSet pod, data
on a `local-path` PVC).

## 4. The single-server assumptions I fixed ← graders look here

| Single-server assumption | Why it breaks on a cluster | How I fixed it |
|---|---|---|
| migrate-on-boot in the entrypoint | 2+ replicas race on `alembic upgrade head` | migration **Job** as an Argo **PreSync hook** — runs once, before replicas roll |
| named volume on the host | pods reschedule across nodes | Postgres **StatefulSet + PVC** (`local-path` storage class) |
| `ports:` published on the host | many pods/nodes need one front door | **ingress-nginx + Services**, klipper servicelb on node IPs |
| crash = you SSH in and restart | no human in the loop at scale | **Deployments + liveness/readiness/startup probes** self-heal |
| deploy = stop then start (downtime) | requests dropped mid-deploy | **RollingUpdate `maxUnavailable: 0`** + **PDB `minAvailable: 1`** |
| `.env` on disk, trusted | plaintext secret on every box | **ConfigMap** (non-secret) + **out-of-band Secret** |
| flat, trusted local network | no segmentation between tiers | **default-deny NetworkPolicy** + targeted allows (k3s enforces it) |
| one box = one failure domain | box dies → app dies | **3 nodes**, 2+ replicas/tier, **topologySpreadConstraints** |
| `:latest`, rebuild in place | unpinned, irreproducible | **pinned image tags** via kustomize `images:` |

## 5. Choices & trade-offs
- **kustomize (base + overlay)** over Helm/raw — declarative, no templating engine, Argo renders it
  natively; overlay isolates env-specifics (image tags, domain).
- **ingress-nginx over k3s Traefik** — disabled Traefik (`--disable traefik`); nginx for path-based
  same-origin routing and first-class cert-manager integration. Kept klipper servicelb for the LB.
- **NetworkPolicy enforced by k3s' built-in kube-router** — no Calico needed; default-deny + a rule
  for the ACME HTTP-01 solver so cert issuance still works under deny.
- **Secrets via Sealed Secrets (encrypted, in git)** — `manifests/seal-secret.sh` + the
  sealed-secrets controller turn the real Secret into a committable `SealedSecret` only the cluster
  can decrypt, so git holds the full desired state. The plain out-of-band `kubectl apply` of a
  Secret (`secret.example.yaml` shows the shape) remains the simpler fallback.
- **`local-path` storage** — k3s default, simplest; trade-off is the PV is node-pinned (survives pod
  delete, not node loss). HA Postgres is a stretch goal, intentionally deferred.
- **Remote state on OCI Object Storage (S3-compat)** — the OCI "equivalent" of S3; locking is the
  weak spot (no DynamoDB), handled by solo-operator discipline. See `infra-aws/` for the contrast.
- **Argo scoped `AppProject`** over `default` — allowlists the source repo + the four namespaces.
