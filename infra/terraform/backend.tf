terraform {
  backend "s3" {
    bucket         = var.state_bucket_name
    key            = "${var.cluster_name}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.lock_table_name
    encrypt        = true
  }
}

// NOTE: This backend uses variables so you can bootstrap the backend using
// the `remote-state` module (infra/terraform/remote-state). Recommended
// workflow:
// 1) cd infra/terraform/remote-state && terraform init && terraform apply
//    (creates S3 bucket + DynamoDB table)
// 2) Set `state_bucket_name` and `lock_table_name` in your local
//    `terraform.tfvars` (or provide via `-backend-config`)
// 3) cd infra/terraform && terraform init -reconfigure
