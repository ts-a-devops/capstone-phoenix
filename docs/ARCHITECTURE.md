# Architecture

## 1. Topology diagram

```
  Internet
     │
     ▼
  DNS: taskapp.example.com
     │
     ▼
  ingress-nginx (nginx ingress controller)
     │
     ▼
  taskapp namespace
     │
     ├─ frontend Service -> frontend Pods (2 replicas, spread across worker nodes)
     │
     └─ backend Service -> backend Pods (2 replicas, spread across worker nodes)
           │
           └─ postgres Service -> postgres-0 StatefulSet Pod (PVC attached)
```

## 2. Node & network
- Nodes: 1 control-plane node running k3s server, 2 worker nodes running k3s agents.
- The control-plane hosts cluster system components and Argo CD; workers host application Pods.
- Firewall: only TCP 22 from the admin IP, 80 and 443 from the public internet. Kubernetes API port 6443 and node-to-node traffic are restricted to internal networking.

## 3. Request flow
A web request resolves `taskapp.example.com` via DNS to the public load balancer/IP, reaches the nginx ingress controller, and is routed to the frontend Service on port 80. The frontend serves the application and proxies API requests under `/api` to the backend Service on port 5000. The backend in turn connects to PostgreSQL on port 5432 through the postgres Service. TLS is terminated by cert-manager using a ClusterIssuer and a Let’s Encrypt certificate.

## 4. The single-server assumptions you fixed

| Single-server assumption | Why it breaks at scale | How you fixed it |
|---|---|---|
| Single host storage path | If a Pod moves to another node, local host data is lost | PostgreSQL runs in a StatefulSet with a PVC so storage follows the Pod through the cluster storage class. |
| migrate-on-boot in the container entrypoint | Multiple backend replicas race during startup and can corrupt migrations | Migrations are run as a separate Job, decoupling schema changes from replica startup. |
| host-published ports and local routing | Multiple replicas on different nodes cannot all use the same host port safely | Ingress and Services provide a single front door and cluster IP routing to Pods. |
| manual cluster changes | Ad-hoc `kubectl apply` breaks GitOps consistency | Argo CD owns the app state from `gitops/taskapp.yaml`; commits drive syncs. |

## 5. Choices & trade-offs
- Raw YAML vs kustomize: I chose kustomize in `manifests/taskapp/` because it lets me keep a single overlay of app resources without introducing a full Helm chart, and it fits the repository's current structure.
- ingress-nginx vs k3s Traefik: I chose ingress-nginx because it is widely used, well documented, and compatible with cert-manager's HTTP01 solver for TLS.
- CNI / NetworkPolicy enforcement: The app uses namespace-level deny-by-default ingress policies plus allow rules for frontend, backend, and Postgres to reduce lateral movement. This protects the app even if the cluster network is not fully sealed.
- Secrets approach: The repo currently includes a placeholder Secret manifest for local validation only. In production, secrets should be managed out-of-band or with Sealed Secrets / External Secrets, so encrypted values can live safely in git.
