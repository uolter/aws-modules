provider "aws" {
  version = "2.62.0"
  region  = var.aws_region
}


resource "aws_security_group" "this" {
  name                   = var.name
  description            = var.description
  vpc_id                 = var.vpc_id
  name_prefix            = var.name_prefix
  revoke_rules_on_delete = var.revoke_rules_on_delete

  tags = merge({
    Name        = "${var.name}-sg"
    Environment = var.environment
  }, var.tags)

}

resource "aws_security_group_rule" "this" {
  count                    = length(var.security_rules)
  type                     = var.security_rules[count.index].type
  from_port                = var.security_rules[count.index].from_port
  to_port                  = var.security_rules[count.index].to_port
  protocol                 = var.security_rules[count.index].protocol
  cidr_blocks              = var.security_rules[count.index].cidr_blocks
  security_group_id        = aws_security_group.this.id
  description              = var.security_rules[count.index].description
  source_security_group_id = var.security_rules[count.index].source_security_group_id
  self                     = var.security_rules[count.index].self
  ipv6_cidr_blocks         = var.security_rules[count.index].ipv6_cidr_blocks
}
