# infra/terraform/ — provision the nodes

Seed this from your single-EC2 Terraform and grow it to a small fleet.

**Must produce:**
- 1 control-plane VM + **2+ worker VMs** (small instances are fine).
- Modules: `network`, `security_group`/firewall, `compute`.
- **Remote state** (S3 + DynamoDB lock, GCS, etc.) — no `*.tfstate` in git.
- Firewall: world-open only `80`/`443`; `22` from your IP; `6443` and node ports NOT public.
- `outputs.tf`: control-plane + worker IPs (public for SSH, private for k3s join) for Ansible.
- Everything parameterized in `variables.tf`; ship a `terraform.tfvars.example` (real one gitignored).

**Acceptance:** `terraform apply` from clean → you can SSH to every node; `terraform destroy`
leaves nothing behind. Re-running `plan` after apply shows no drift.

> Keep infra lean: one k3s server is fine — you do NOT need a multi-master/HA control plane.
> The difficulty in this capstone lives in Kubernetes, not the control plane.

Remote state setup (example)
----------------------------

Before running `terraform init` for real, create a remote S3 bucket and DynamoDB table for state locking. Example commands (AWS):

```bash
# create S3 bucket (replace names)
aws s3api create-bucket --bucket my-capstone-terraform-state --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1

# create DynamoDB table for locks
aws dynamodb create-table --table-name my-capstone-terraform-locks --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region us-east-1
```

Then edit `backend.tf` and replace the placeholder `bucket` and `dynamodb_table` values with your actual names. Run:

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Security note: do NOT commit the real `terraform.tfvars` with secrets (keep it in your local filesystem and add it to `.gitignore`).
