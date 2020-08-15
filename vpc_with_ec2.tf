provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "dev" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev"
    created_by = "terraform"
  }
}

resource "aws_subnet" "private-subnet-a"{
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1a"
    created_by = "terraform"
  }
}

resource "aws_subnet" "private-subnet-c"{
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1c"
    created_by = "terraform"
  }
}

resource "aws_subnet" "public-subnet-a"{
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1a"
    created_by = "terraform"
  }
}

resource "aws_subnet" "public-subnet-c"{
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-southeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1c"
    created_by = "terraform"
  }
}

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev"
    created_by = "terraform"
  }
}

resource "aws_eip" "nat-eip" {
  vpc      = true
}


resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public-subnet-a.id
  depends_on = [aws_internet_gateway.dev-igw]
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "public-rt"
    created_by = "terraform"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "private-rt"
    created_by = "terraform"
  }
}

resource "aws_route_table_association" "private-asc-a" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private-asc-c" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "public-asa" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-asc" {
  subnet_id      = aws_subnet.public-subnet-c.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_instance" "web" {
  ami = "ami-0007cf37783ff7e10"
  instance_type = "t2.micro"
  availability_zone = "ap-southeast-1a"
  subnet_id = aws_subnet.private-subnet-a.id

  tags = {
    Name: "web"
    created_by = "terraform"
  }
}

resource "aws_instance" "db" {
  ami = "ami-0007cf37783ff7e10"
  instance_type = "t2.micro"
  availability_zone = "ap-southeast-1a"
  subnet_id = aws_subnet.public-subnet-a.id
  
  tags = {
    Name: "db"
    created_by = "terraform"
  }
}
