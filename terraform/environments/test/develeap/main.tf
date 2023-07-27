provider "aws" {
  region = var.region
}

data "aws_region" "current" {}


module "vpc" {
  create_vpc          = true
  source              = "../../../modules/develeap/aws-vpc"
  cidr_block          = var.cidr_block
  azs                 = var.azs
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  enable_nat_gateway  = true
  public_eks_tag      = var.public_eks_tag
  private_eks_tag     = var.private_eks_tag
  prefix              = var.prefix
  project             = var.project
  application         = var.application
  eks_cluster_name    = var.prefix
}

module "sg" {
  source      = "../../../modules/develeap/sg"
  vpc_id      = module.vpc.vpc_id
  prefix      = var.prefix
  project     = var.project
  application = var.application

}

module "eks" {
  source                  = "../../../modules/develeap/eks"
  cluster_name            = var.prefix
  k8s_version             = var.k8s_version
  node_instance_type      = var.node_instance_type
  desired_capacity        = var.desired_capacity
  max_size                = var.max_size
  min_size                = var.min_size
  max_unavailable         = var.max_unavailable
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = module.vpc.vpc_cidr
  endpoint_private_access = true
  endpoint_public_access  = true
  subnet_ids              = module.vpc.subnet_ids
  private_subnets         = module.vpc.private_subnets
  vpc_subnet_cidr         = module.vpc.vpc_cidr
  private_subnet_cidr     = module.vpc.private_subnets_cidr_blocks
  public_subnet_cidr      = module.vpc.public_subnets_cidr_blocks
  eks_cw_logging          = var.eks_cw_logging
  prefix                  = var.prefix
  project                 = var.project
  application             = var.application
  aws_iam                 = var.aws_iam
}
