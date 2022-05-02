resource "aws_default_security_group" "default-sg" {

  vpc_id = var.vpc_id

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
    name = "name"
    #values = ["amzn2-ami-*-x86_64-gp2"]
    values = [var.ami_name]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "my-instance" {
  ami           = data.aws_ami.aws-linux-latest.id
  instance_type = var.instance_type
  /*   subnet_id                   = module.my-subnet.subnet.id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id] */
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  #key_name = "aws"
  key_name  = aws_key_pair.ssh-key.key_name
  user_data = file("entry.sh")
  tags = {
    "Name" = "${var.env}-server"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = file(var.public_key_path)
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

