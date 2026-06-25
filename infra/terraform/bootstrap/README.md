# bootstrap/ — remote-state backend (run once, before the root module)

This is the "terraform-backend" step: it creates the **OCI Object Storage bucket** that the
root module (`infra/terraform/root/`) uses for remote state. It has its **own local state**, which
is gitignored and disposable — the bucket it creates is trivially recreatable, so there's no
chicken-and-egg.

## Run order
```bash
cd infra/terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars   # fill compartment_ocid + region
terraform init                                  # local state
terraform apply
terraform output                                # note bucket name, namespace, s3 endpoint
```

Then, **one manual step Terraform can't do for you**: generate S3-compatible
**Customer Secret Keys** (OCI console → your profile → *Customer secret keys → Generate*).
These become `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` for the root backend
(see notes/oracle-cloud-setup.md §5).

Finally, wire the outputs into `root/backend.tf` and run `terraform init` in
`infra/terraform/root/`.

> Do **not** add a remote `backend` block here — bootstrap must use local state by design.
> Its `*.tfstate` is covered by the repo `.gitignore`.
