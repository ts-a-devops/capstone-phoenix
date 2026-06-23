terraform {
  required_version = ">= 1.0"

  backend "s3" {
    # Replace these values with a real remote state bucket and lock table
    bucket         = "REPLACE_WITH_REMOTE_STATE_BUCKET"
    key            = "capstone-phoenix/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_WITH_LOCK_TABLE"
    encrypt        = true
  }
}
