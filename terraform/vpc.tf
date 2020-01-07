module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.9.0"

  name = format("%s-vpc", var.name)
  azs  = var.vpc_azs
  cidr = var.vpc_cidr

  public_subnets   = var.vpc_public_subnets
  private_subnets  = var.vpc_private_subnets
  database_subnets = var.vpc_database_subnets

  enable_nat_gateway     = var.vpc_enable_nat_gateway
  single_nat_gateway     = var.vpc_single_nat_gateway
  one_nat_gateway_per_az = var.vpc_one_nat_gateway_per_az

  tags = {
    Group       = var.name
    Environment = var.vpc_env
  }
}
