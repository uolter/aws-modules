variable "aws_region" {
  type = string

}

variable "environment" {
  type        = string
  description = "The name of the environment."
}

variable "owner" {
  type        = string
  description = "The Owner tag"
}

variable "name" {
  type        = string
  description = "The name of the security group. If omitted, Terraform will assign a random, unique name"
  default     = null
}

variable "name_prefix" {
  type        = string
  default     = null
  description = "Creates a unique name beginning with the specified prefix. Conflicts with name."
}

variable "description" {
  type        = string
  default     = null
  description = "The security group description. "
}

variable "vpc_id" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags, each pair."
  default     = null
}

variable "revoke_rules_on_delete" {
  type        = bool
  default     = false
  description = "Instruct Terraform to revoke all of the Security Groups attached ingress and egress rules before deleting the rule itself. "
}

variable "security_rules" {
  type = list(object({
    type                     = string
    from_port                = number
    description              = string
    to_port                  = number
    protocol                 = string
    cidr_blocks              = list(string)
    source_security_group_id = string
    self                     = bool
    ipv6_cidr_blocks         = list(string)
  }))
  default = []

}
