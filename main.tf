provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env" {}
variable "myip" {}

variable "instance_type" {}
variable "public_key_path" {}
resource "aws_vpc" "dev" {

  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env}-subnet"
  }
}

/* resource "aws_route_table" "my_rtb" { 
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    "Name" = "${var.env}-rtb"
  }
} 

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.my_rtb.id
}*/

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.dev.id
  tags = {
    "Name" = "${var.env}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.dev.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    "Name" = "${var.env}-main-rtb"
  }

}

/* resource "aws_security_group" "my-sg" {
  name        = "${var.env}-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.myip]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080 
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" #any
    cidr_blocks      = ["0.0.0.0/0"]
   # ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "${var.env}-sg"
  }

}
 */

resource "aws_default_security_group" "default-sg" {

  vpc_id = aws_vpc.dev.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myip]

    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #any
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "${var.env}-default-sg"
  }

}

data "aws_ami" "aws-linux-latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

output "aws-ami" {
  value = data.aws_ami.aws-linux-latest.id
}
/* output "aws_instance" {
  value = data.aws_instance.my-instance.pu
} */
resource "aws_instance" "my-instance" {
  ami                         = data.aws_ami.aws-linux-latest.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  #key_name = "aws"
  key_name  = aws_key_pair.ssh-key.key_name
  user_data                   = file("entry-script.sh")

  tags = {
    Name = "${var.env}-instance"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = file(var.public_key_path)
}
