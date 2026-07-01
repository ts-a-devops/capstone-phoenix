infra: add Terraform skeleton and module placeholders

This adds a minimal Terraform skeleton to bootstrap multi-node infra for the capstone:

- Adds `infra/terraform/` with:
  - `backend.tf` — remote-state S3 backend placeholder
  - `variables.tf`, `main.tf`, `outputs.tf`
  - module placeholders under `modules/` (`vpc`, `control`, `worker`) with README.md guidance
- Purpose: provide a reproducible scaffold for the full infra (network, security, compute, remote state) without leaking credentials or state.

Notes:
- Backend values in `backend.tf` are intentionally placeholders — do NOT commit real state credentials.
- This is a scaffolding PR; modules must be implemented in follow-up PRs.
- See `infra/terraform/README.md` for usage notes and suggested workflow.

How to review:
- Inspect added files under `infra/terraform/`.
- Confirm variable names and outputs align with the Ansible playbooks you plan to write (kube join needs control private IP and token).
- No runtime secrets or state files are included.

Checklist
- [ ] Remote state placeholder: `infra/terraform/backend.tf` present with S3/DynamoDB placeholders.
- [ ] Variables: `infra/terraform/variables.tf` exposes runtime params (SSH key, allowed CIDR, instance types, counts).
- [ ] Outputs: `infra/terraform/outputs.tf` exports control and worker IPs for Ansible consumption.
- [ ] Module placeholders: `modules/vpc`, `modules/control`, `modules/worker` added with README guidance.
- [ ] README: `infra/terraform/README.md` documents init/plan workflow and security notes.
- [ ] No secrets/state: repo contains no `*.tfstate`, private keys, or credentials.
- [ ] Next PR plan documented: implement modules, remote state bucket creation, security group rules.

Commands to push after you fork:
```bash
git remote add fork https://github.com/Precious2003/capstone-phoenix.git
git push --set-upstream fork feature/infra-terraform-skeleton
gh pr create --repo ts-a-devops/capstone-phoenix --head Precious2003:feature/infra-terraform-skeleton --base main --title "infra: add Terraform skeleton and module placeholders" --body-file PR_BODY.md
```
