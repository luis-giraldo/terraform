
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

module "my-subnet" {
  source                 = "./modules/subnet"
  subnet_cidr_block      = var.subnet_cidr_block
  avail_zone             = var.avail_zone
  env                    = var.env
  vpc_id                 = aws_vpc.dev.id
  default_route_table_id = aws_vpc.dev.default_route_table_id
}

module "my-webserver" {
  source          = "./modules/webserver"
  env             = var.env
  vpc_id          = aws_vpc.dev.id
  myip            = var.myip
  ami_name        = var.ami_name
  instance_type   = var.instance_type
  subnet_id       = module.my-subnet.subnet.id
  avail_zone      = var.avail_zone
  public_key_path = var.public_key_path

}
