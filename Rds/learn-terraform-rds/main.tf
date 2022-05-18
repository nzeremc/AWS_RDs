provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "demo"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "education" {
  name       = "demo"
  subnet_ids = ["subnet-0c7ceaff0743603c7","subnet-0513db4c77089e7e0"]

  tags = {
    Name = "Demo"
  }
}

resource "aws_security_group" "rds" {
  name   = "demo_rds"
  vpc_id = "vpc-02e2e6f2cc3ef6f72"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo_rds"
  }
}

resource "aws_db_parameter_group" "demo" {
  name   = "demo"
  family = "mysql8.0"
}

resource "aws_db_instance" "demo" {
  identifier             = "demo"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "MySQL"
  engine_version         = "8.0.28"
  username               = "emmy"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.education.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.demo.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}
