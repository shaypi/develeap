variable "prefix" {}
variable "project" {}
variable "region" {}
variable "cidr_block" {}
variable "azs" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}
variable "k8s_version" {}
variable "node_instance_type" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "min_size" {}
variable "eks_cw_logging" {}

variable "application" {
  type = string
}
variable "public_eks_tag" {
  description = "tag needed for eks"
  type        = map(any)
}
variable "private_eks_tag" {
  description = "tag needed for eks"
  type        = map(any)
}

variable "max_unavailable" {}
variable "aws_iam" {}
