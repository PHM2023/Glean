locals {
  # TODO(Venkat, Jayesh): If need be convert the following into variables that are read from configs
  vpc_cidr                = "10.1.0.0/16"
  public_subnet_cidr      = "10.1.16.0/20"
  public_subnet_2_cidr    = "10.1.128.0/24"
  eks_private_subnet_cidr = "10.1.32.0/20"
  codebuild_subnet_cidr   = "10.1.48.0/24"
  rds_subnet_1_cidr       = "10.1.64.0/25"
  rds_subnet_2_cidr       = "10.1.64.128/25"
  bastion_subnet_cidr     = "10.1.80.0/24"
  lambda_subnet_cidr      = "10.1.0.0/24"
  git_crawler_subnet_cidr = "10.1.1.0/26"
}
