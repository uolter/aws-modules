provider "aws" {
  version = "2.62.0"
  region  = var.aws_region
}


resource "aws_security_group" "allow_tls" {
  name        = var.aws_security_group_name
  description = var.aws_security_group_description
  vpc_id  = var.vpc_id
  name_prefix = var.name_prefix
  revoke_rules_on_delete  = var.revoke_rules_on_delete 
  tags = {
    Name        = var.vpc_name
    Owner       = var.owner
    Environment = var.environment
  }
}