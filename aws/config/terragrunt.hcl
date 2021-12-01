locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  account_id = local.account_vars.locals.aws_account_id
  aws_region = local.region_vars.locals.aws_region
}

iam_role = "arn:aws:iam::${local.account_id}:role/terraform_rw"

remote_state {
  backend = "s3"
  config = {
    bucket  = "%CUSTOMER_NAME%-terraform-${local.account_id}"
    region  = "%REMOTE_STATE_BUCKET_REGION%"
    encrypt = true
    key     = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids = ["${local.account_id}"]
}
EOF
}

