resource "aws_subnet" "subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env}-subnet"
  }
}

/* resource "aws_route_table" "my_rtb" { 
  vpc_id = var.vpc_id

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
  vpc_id = var.vpc_id
  tags = {
    "Name" = "${var.env}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = var.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    "Name" = "${var.env}-main-rtb"
  }

}
