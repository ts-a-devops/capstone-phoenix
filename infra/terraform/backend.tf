terraform {
  backend "s3" {
    # Run infra/terraform/remote-state/ first to create this bucket and table.
    # Then replace these placeholders and run: terraform init -reconfigure
    bucket         = "REPLACE_WITH_REMOTE_STATE_BUCKET"
    key            = "capstone-phoenix/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_WITH_LOCK_TABLE"
    encrypt        = true
  }
}
