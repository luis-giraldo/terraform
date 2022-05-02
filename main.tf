
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs = [var.avail_zone]
  public_subnets = [var.subnet_cidr_block]
  public_subnet_tags = {
    Name = "${var.env}-subnet-1"

  }
  tags = {
    Name        = "${var.env}-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
}

module "my-webserver" {
  source          = "./modules/webserver"
  env             = var.env
  vpc_id          = module.vpc.vpc_id
  myip            = var.myip
  ami_name        = var.ami_name
  instance_type   = var.instance_type
  subnet_id       = module.vpc.public_subnets[0]
  avail_zone      = var.avail_zone
  public_key_path = var.public_key_path

}
