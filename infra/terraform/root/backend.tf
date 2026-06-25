# Remote state in OCI Object Storage via its S3-compatible API (the brief's "S3 equivalent").
#
# Backend blocks cannot use variables, so these values are literal — fill them from the
# `bootstrap` outputs (`cd ../bootstrap && terraform output`) before running `terraform init` here.
#
# The backend authenticates with S3 Customer Secret Keys, NOT the API signing key. Export them
# first (never commit them):
#   export AWS_ACCESS_KEY_ID=<customer secret access key>
#   export AWS_SECRET_ACCESS_KEY=<customer secret secret key>
terraform {
  backend "s3" {
    bucket = "phoenix-tfstate"            # = bootstrap output `state_bucket_name`
    key    = "phoenix/terraform.tfstate"
    region = "uk-london-1"                # any value; OCI ignores it (skip_region_validation)

    endpoints = {
      # = bootstrap output `s3_compat_endpoint` — replace <NAMESPACE> and the region:
      s3 = "https://<NAMESPACE>.compat.objectstorage.uk-london-1.oraclecloud.com"
    }

    use_path_style              = true
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    # use_lockfile = true   # enable if OCI S3-compat honors conditional-write locks; else solo-operator workflow
  }
}
