module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "${var.basename}-vpc-${var.environment}"
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr                 = var.vpc_cidr
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # These tags are neccessary so ingress controller can attach the load balancer to the subnets
  tags = {
    "kubernetes.io/cluster/${var.basename}-${var.environment}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.basename}-${var.environment}" = "shared"
    "kubernetes.io/role/elb"                                   = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.basename}-${var.environment}" = "shared"
    "kubernetes.io/role/internal-elb"                          = "1"
  }
}
