provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

variable "cidr_block" {
    type = "string"
    default = "10.0.0.0/26"
}

variable "subnet1_cidr_block" {    
    default = "10.0.0.0/28"
}

variable "subnet2_cidr_block" {
    default = "10.0.0.32/28"
}

#vpc resource
resource "aws_vpc" "myvpc2" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "vpc2"
  }
}

#subnet 
resource "aws_subnet" "private-subnet-a" {
  vpc_id     = aws_vpc.myvpc2.id
  cidr_block = var.subnet1_cidr_block

  tags = {
    Name = "subnet-private-a"
  }
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id     = aws_vpc.myvpc2.id
  cidr_block = var.subnet2_cidr_block

  tags = {
    Name = "subnet-public-a"
  }
}


#igw
resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.myvpc2.id

  tags = {
    Name = "igw2"
  }
}

# public RT 

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw2.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet-a.id
  depends_on    = [aws_internet_gateway.igw2]
}



resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.myvpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "privateRouteTable"
  }
}

resource "aws_route_table_association" "private-subnet" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "public-subnet" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public_rt.id
}


# these values will be o/p to console

output "vpc_id" {
    value = aws_vpc.myvpc2.id
}

