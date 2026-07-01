# Runbook (fill this in — a teammate must rebuild from this alone)

## Provision from zero
```bash
# 1. infrastructure
cd infra/terraform
terraform init
terraform apply -auto-approve

# 2. cluster bootstrap
cd ../ansible
ansible-playbook -i inventory.ini site.yml \
  --private-key /path/to/capstone-key.pem \
  -u ubuntu \
  --ssh-extra-args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

# 3. kubeconfig
export KUBECONFIG=$(pwd)/artifacts/kubeconfig
kubectl get nodes

# 4. GitOps app deploy
kubectl apply -f ../gitops/taskapp.yaml
# The Argo CD controller will sync the app automatically.

# 5. verify
kubectl get ns taskapp
kubectl get pods -n taskapp
kubectl get ingress -n taskapp
```

## Day-2 operations
- **Scale a tier:** commit a change to `manifests/taskapp/backend-deployment.yaml` or `frontend-deployment.yaml`, push to git, then watch Argo CD auto-sync. Avoid manual `kubectl scale` so GitOps remains source of truth.
- **Roll back a bad deploy:** revert the manifest commit, push it, and confirm Argo CD restores the previous desired state.
- **Run a new migration safely:** update the migration Job image/command in `manifests/taskapp/migration-job.yaml`, push, and let Argo CD apply it. Keep migration logic separate from the long-running backend replicas.
- **Rotate a secret:** create a new secret out-of-band (or use Sealed Secrets/External Secrets in a later stretch), then update the GitOps manifests to reference the new secret name if needed.

## Failure recovery
- **A worker node dies / is drained:** the scheduler reschedules Pods onto remaining nodes. Use:
  ```bash
  kubectl drain <worker-node> --ignore-daemonsets --delete-emptydir-data
  kubectl get pods -n taskapp -o wide
  ```
  Expected recovery: frontend/backend replicas should restart on the remaining workers, and the PostgreSQL StatefulSet should stay bound to its existing PVC.
- **A backend Pod crashloops:** diagnose with:
  ```bash
  kubectl -n taskapp logs deploy/backend
  kubectl -n taskapp describe pod <pod-name>
  kubectl -n taskapp get events
  ```
- **A bad migration:** if the migration Job fails, inspect the Job logs and fix the migration command or database state. Use a database restore from the backup CronJob if available.
- **Postgres Pod is rescheduled:** verify the PVC remains attached and the data directory is intact with:
  ```bash
  kubectl -n taskapp get pvc
  kubectl -n taskapp describe pod postgres-0
  ```
  Data should persist across rescheduled pods because the StatefulSet uses a persistent volume claim.
