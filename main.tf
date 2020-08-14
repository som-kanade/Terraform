
provider "aws" {
  region  = "ap-southeast-1"
  access_key = "add your access_key here"
  secret_key = "add your secret keys here"
}

resource "aws_vpc" "dev" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "dev" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "dev"
  }
}


resource "aws_key_pair" "dev-key" {
  key_name = "dev-key-by-terraform"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"

}

resource "aws_ebs_volume" "dev" {
  availability_zone = "ap-southeast-1b"
  size              = 10

  tags = {
    Name = "dev"
  }
}

resource "aws_instance" "ec2-dev" {
  ami = "ami-0cd31be676780afa7"
  instance_type = "t2.micro"
  availability_zone = "ap-southeast-1b"
  key_name = "dev-key-by-terraform"
  subnet_id = "subnet-0aba062bce6cb8a5f"
  vpc_security_group_ids = ["sg-088dbe4bc846babe1"]
  associate_public_ip_address = true
  


  tags = {
    Name = "dev"
    created_by = "Terraform"
  }

}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.dev.id
  instance_id = aws_instance.ec2-dev.id
}








