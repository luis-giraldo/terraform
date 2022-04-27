provider "aws" {

}

variable "otherider" {
    description = "other cidr block"
    type = list

}
resource "aws_vpc" "dev" {

  cidr_block = var.otherider[1]
  tags = {
    #Name = "dev"
  }
}

variable "subnet-cidr-block" {
  description = "subnet cidr block"
  
}

resource "aws_subnet" "dev-subnet" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = var.subnet-cidr-block #"10.0.1.0/24"
  #variable = var.subnet-cidr-block

}

data "aws_vpc" "existing-vpc" {
  default = true
}
resource "aws_subnet" "dev-subnet-2" {
  vpc_id = data.aws_vpc.existing-vpc.id
  cidr_block = "172.31.96.0/20"    
 # availability_zone = "us-east-1"

}

output "dev-vpc-id" {
  value = aws_vpc.dev.id
}
