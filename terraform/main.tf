provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "charlie-cluster"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr                 = var.vpc_cidr
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # These tags are neccessary so ingress controller can attach the load balancer to the subnets
  tags = {
    "kubernetes.io/cluster/charlie-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/charlie-cluster" = "shared"
    "kubernetes.io/role/elb"                = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/charlie-cluster" = "shared"
    "kubernetes.io/role/internal-elb"       = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.26.1"

  cluster_version = "1.31"
  cluster_name    = "charlie-cluster"

  enable_cluster_creator_admin_permissions = true

  //TODO:  it would be nice to use private but there is one missing security group rule to allow this. 
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true
  # EKS Managed Node Group(s)

  eks_managed_node_group_defaults = {
    instance_types = ["t2.medium"]
  }

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.medium"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }
  authentication_mode = "API_AND_CONFIG_MAP"
}

resource "aws_ecr_repository" "app1" {
  name                 = "app1"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
