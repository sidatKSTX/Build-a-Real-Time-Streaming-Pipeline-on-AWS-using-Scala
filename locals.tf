locals {
  region     = var.aws_region
  account_id = var.aws_account_id != null ? var.aws_account_id : data.aws_caller_identity.current.account_id
}