# gitops/ — Argo CD owns the cluster

This is your **Portainer GitOps, leveled up to Kubernetes**. The cluster's desired state
lives in *this git repo*; Argo CD continuously syncs it. Your final, graded state must be
reconciled by Argo — not by you running `kubectl apply` by hand.

**Produce:**
- Install Argo CD (manifest or Helm) — document how in RUNBOOK.md.
- An Argo CD `Application` (this folder) pointing at `manifests/` (or your Helm/kustomize path),
  with `syncPolicy.automated` (prune + selfHeal). App-of-apps if you split platform vs app.

**Acceptance / demo (required for the GitOps points):**
1. `argocd app get taskapp` → `Synced` + `Healthy`.
2. Commit a change (e.g. bump frontend replicas 2→3), push.
3. Show Argo auto-syncing and the new Pod appearing — **no manual apply.**

**Stretch — DONE:** the loop is `app repo cd.yaml` (build + push to GHCR, then `repository_dispatch`)
→ this repo's `.github/workflows/bump-image.yml` (rewrites the overlay tag, pushes) → Argo auto-syncs.
The app-repo side is `docs/examples/app-cd.example.yaml`; the bump side runs here.

> Secrets + GitOps: don't commit a plaintext Secret to satisfy "git owns everything." Use
> Sealed Secrets / External Secrets (stretch) so the encrypted form is safe in git, or create
> the Secret out-of-band and let Argo ignore it. State your choice in ARCHITECTURE.md.
