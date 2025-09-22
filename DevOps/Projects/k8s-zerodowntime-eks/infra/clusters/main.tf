# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project}-vpc"
  cidr = "10.0.0.0/16"

  azs             = [for az in slice(data.aws_availability_zones.available.names, 0, 3) : az]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = { Project = var.project }
}

# EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project}-eks"
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

eks_managed_node_groups = {
  default = {
    # Give AWS many choices so capacity isn't a problem
    instance_types = ["t3.medium", "t3a.medium", "t3.large", "t3a.large", "m5.large", "c5.large", "c6i.large"]

    # Start small, then scale later
    desired_size  = 1
    min_size      = 1
    max_size      = 3

    # Keep it simple & reliable
    ami_type      = "AL2_x86_64"
    capacity_type = "ON_DEMAND"
  }
}


  tags = { Project = var.project }
}

# ECR
resource "aws_ecr_repository" "app" {
  name                 = "${var.project}-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Project = var.project }
}
