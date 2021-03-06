data "aws_region" "current" {}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "govuk/infra-networking.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "infra_root_dns_zones" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "govuk/infra-root-dns-zones.tfstate"
    region   = data.aws_region.current.name
    role_arn = var.assume_role_arn
  }
}
