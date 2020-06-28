variable "aws_region" {
  type = string

}

variable "vpc_cidr" {
  type = string
}

variable "environment" {
  type        = string
  description = "The name of the environment."
}

variable "vpc_name" {
  type        = string
  description = "The name of the vpc."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags, each pair."
  default     = null
}

variable "public_subnets_cidr" {
  type = list
}

variable "private_subnets_cidr" {
  type    = list
  default = []
}

variable "azs" {
  type        = list
  description = "List of availability zones"
}

variable "instance_tenancy" {
  type        = string
  default     = null
  description = "A tenancy option for instances launched into the VPC"
}

variable "enable_dns_support" {
  type        = bool
  description = "A boolean flag to enable/disable DNS support in the VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  default     = false
}

variable "assign_generated_ipv6_cidr_block" {
  type        = string
  description = "assign_generated_ipv6_cidr_block"
  default     = false
}

## Internet Gateway
variable "enable_internet_gateway" {
  type        = bool
  description = "Enable internet gateway"
  default     = false
}

## Nat Gateway
variable "enable_nat_gateway" {
  type        = bool
  description = "Enable nat gateway"
  default     = false
}

locals {
  internet_gateway_name = "${var.vpc_name}-${var.environment}-igw"
}
