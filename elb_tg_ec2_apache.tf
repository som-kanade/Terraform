# all ip address allowed in SG inbound rules please make sure only needed ips/cidrs allowed if using thos script 
# please secure Resources accordingly

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

variable "vpc_id" {
    default = "vpc-64b25402"
}

variable "subnet1" {
    default = "subnet-4bba3c12"
}

variable "subnet2"{
    default = "subnet-ec966da4"
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


resource "aws_lb" "elb" {
  name               = "elb1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = [var.subnet1,var.subnet2]

  tags = {
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "tg1" {

  health_check {
      protocol = "HTTP"
      path = "/"
      healthy_threshold =  5
      unhealthy_threshold = 2
      timeout = 5
      interval =  30
  }

  name     = "tg1"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = var.vpc_id
}

resource "aws_instance" "web" {
    ami = "ami-07d58f1b1a396bab3"
    instance_type = "t2.micro"
    subnet_id = var.subnet1
    security_groups = [aws_security_group.allow_tls.id]

    tags = {
        Name: "dev-ec2"
    }
}


resource "aws_lb_listener" "dev" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"

    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
}

resource "aws_lb_target_group_attachment" "dev" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id        = aws_instance.web.id
  port             = 80
}
