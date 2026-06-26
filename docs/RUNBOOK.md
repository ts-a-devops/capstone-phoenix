# Runbook — Phoenix TaskApp on OCI k3s

A teammate should be able to rebuild the live, HTTPS, multi-node, GitOps-managed cluster from
this file alone. Cloud: **Oracle Cloud (OCI)**, region **eu-paris-1**.

## 0. Prerequisites (once)
```bash
brew install terraform ansible kubectl oci-cli helm jq
ssh-keygen -t ed25519 -f ~/.ssh/oci_phoenix -C phoenix     # node SSH key
# OCI: sign up, UPGRADE to Pay As You Go (dodges A1 capacity), create an API key in
# ~/.oci/config (see notes/oracle-cloud-setup.md §3). Have a domain you control.
```
Fill the gitignored real values before applying:
- `infra/terraform/root/terraform.tfvars` — `compartment_ocid`, `allowed_ssh_cidr` (your IP /32), `region = "eu-paris-1"`
- `gitops/*` and `manifests/overlays/prod/kustomization.yaml` — replace every `CHANGEME` / `REPLACE_*` (fork URL, domain, email, image tags)

## 1. Remote-state backend (run once)
```bash
cd infra/terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars     # set compartment_ocid + region=eu-paris-1
terraform init && terraform apply
terraform output                                 # note bucket name, namespace, s3 endpoint
# OCI console -> profile -> Customer secret keys -> Generate (the S3 creds for the backend)
export AWS_ACCESS_KEY_ID=<access key>
export AWS_SECRET_ACCESS_KEY=<secret key>
```
Edit `infra/terraform/root/backend.tf`: set `bucket`, the `endpoints.s3` (your namespace), and
`region` — all to **eu-paris-1**.

## 2. Infrastructure — 3 nodes, VCN, firewall
```bash
cd ../root
cp terraform.tfvars.example terraform.tfvars     # compartment_ocid, allowed_ssh_cidr, region
terraform init                                   # migrates state to Object Storage
terraform apply                                  # 1 server + 2 workers, NSG, public subnet
terraform output                                 # server/worker public + private IPs
```

## 3. Cluster bring-up — k3s via Ansible
```bash
cd ../../ansible
./inventory/generate-inventory.sh                # builds inventory/hosts.yml from TF outputs
ansible-playbook site.yml                         # hardening -> k3s server -> agents -> kubeconfig
ansible-playbook site.yml                         # RUN AGAIN: must report changed=0 (idempotent)
export KUBECONFIG="$PWD/kubeconfig"
kubectl get nodes -o wide                         # server + 2 workers = Ready
```

## 4. Provide the Secret — pick one
Fill real values first: `cp manifests/base/secret.example.yaml /tmp/secret.yaml` (set
`POSTGRES_PASSWORD`, `SECRET_KEY`, `DATABASE_URL`).

**Option A — Sealed Secrets (git-native, recommended).** Do this *after* step 5 brings up the
sealed-secrets controller, then git holds the encrypted Secret:
```bash
manifests/seal-secret.sh /tmp/secret.yaml      # -> manifests/base/taskapp-sealedsecret.yaml
# add taskapp-sealedsecret.yaml to manifests/base/kustomization.yaml resources, commit, push
# Argo syncs it; the controller decrypts it in-cluster into the taskapp-secret Secret
```

**Option B — out-of-band (simplest).** Apply a plain Secret by hand; Argo ignores it:
```bash
kubectl create namespace taskapp
kubectl apply -n taskapp -f /tmp/secret.yaml
```

## 5. GitOps takes over — install Argo CD, hand it the cluster
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-repo-server
kubectl apply -f ../../gitops/appproject.yaml    # scoped project (must exist first)
kubectl apply -f ../../gitops/root-app.yaml       # app-of-apps
```
Argo now syncs by sync-wave: **ingress-nginx (-2) → cert-manager (-1) → taskapp (0)**. From here,
**no manual `kubectl apply`** — git is the source of truth.

## 6. DNS + TLS
```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller   # note EXTERNAL-IP (node IP via klipper)
# At your registrar: A record  taskapp.<your-domain>  ->  that IP
kubectl -n taskapp get certificate                          # taskapp-tls -> READY=True
curl -vI https://taskapp.<your-domain>                      # valid Let's Encrypt cert, HTTP 200
```

---

## Day-2 operations
> Argo has `selfHeal: true` — make changes **in git**, not with `kubectl`, or they get reverted.

- **Scale a tier:** edit `replicas` (frontend) in `manifests/overlays/prod`, commit, push → Argo syncs.
  (Backend replicas are owned by the HPA; Argo ignores `/spec/replicas` for it.)
- **Deploy a new build:** bump the image `newTag` in `overlays/prod/kustomization.yaml`, commit, push.
  The migration Job (PreSync hook) runs `alembic upgrade head` before the new pods roll.
- **Roll back a bad deploy:** `git revert` the tag bump and push (or `argocd app rollback taskapp`).
- **Rotate a secret:** update `/tmp/secret.yaml`, `kubectl apply -n taskapp -f`, then
  `kubectl -n taskapp rollout restart deploy/taskapp-backend`.

## Failure recovery (one is demoed live)
- **Worker node dies / is drained** — the live demo:
  ```bash
  kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
  ```
  topologySpread keeps a replica on another node; the PDB (`minAvailable: 1`) blocks full
  eviction; displaced pods reschedule in ~30–60s. App stays up. `kubectl uncordon <node>` after.
- **Backend Pod crashloops:**
  ```bash
  kubectl -n taskapp logs deploy/taskapp-backend --previous
  kubectl -n taskapp describe pod <pod>      # check probe failures / env / image
  kubectl -n taskapp get events --sort-by=.lastTimestamp
  ```
- **A bad migration:** the PreSync hook fails → Argo halts the sync, so the *old* version keeps
  serving (no half-broken deploy). Fix the migration or `alembic downgrade`, then re-sync.
- **Postgres Pod rescheduled:** `kubectl -n taskapp delete pod taskapp-postgres-0` → it reschedules
  **on the same node** (the `local-path` PV is node-pinned), the PVC re-attaches, data intact.
  ⚠ Caveat: `local-path` does NOT survive node *loss* — for the failover demo, drain a worker that
  is **not** running postgres. (HA Postgres is a brief stretch goal.)
