provider "aws" {
  alias  = "east"
  region = "us-east-1"
}

//Create a VPC//
resource "aws_vpc" "tfvpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    "Name" = "tfvpc"
  }
}

//Private Subnet//
resource "aws_subnet" "tfsubpri" {
  vpc_id            = aws_vpc.tfvpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    "Name" = "tfsubpri"
  }
}

//Public Subnet//
resource "aws_subnet" "tfsubpub" {
  vpc_id            = aws_vpc.tfvpc.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.0.2.0/24"

  tags = {
    "Name" = "tfsubpub"
  }
}

//Private Routetable//
resource "aws_route_table" "tfroupri" {
  vpc_id = aws_vpc.tfvpc.id

  tags = {
    "Name" = "tfroupri"
  }
}

//Associate Private Routetable//
resource "aws_route_table_association" "tfaprou" {
  subnet_id      = aws_subnet.tfsubpri.id
  route_table_id = aws_route_table.tfroupri.id
}

//Public Routetable//
resource "aws_route_table" "tfroupub" {
  vpc_id = aws_vpc.tfvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfig.id
  }

  tags = {
    "Name" = "tfroupub"
  }
}

//Associate Public Routetable//
resource "aws_route_table_association" "tfapbrou" {
  subnet_id      = aws_subnet.tfsubpub.id
  route_table_id = aws_route_table.tfroupub.id
}

//Internet Gateway//
resource "aws_internet_gateway" "tfig" {
  vpc_id = aws_vpc.tfvpc.id

  tags = {
    "Name" = "tfig"
  }
}

//Security Groups//
resource "aws_security_group" "tfsg" {
  name        = "tfsg"
  description = "tfsg"
  vpc_id      = aws_vpc.tfvpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "tfsg"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "tfsg"
    from_port   = 1
    to_port     = 65534
    protocol    = "tcp"
  }
  tags = {
    "Name" = "tfsg"
  }
}

//AWS Instance//
resource "aws_instance" "tfinstance" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  key_name               = "terraformkey"
  subnet_id              = aws_subnet.tfsubpub.id
  vpc_security_group_ids = ["${aws_security_group.tfsg.id}"]

  tags = {
    "Name" = "tfinstance"
  }
}

//Elastic IP//
resource "aws_eip" "tfip" {
  instance = aws_instance.tfinstance.id
  vpc      = true

  tags = {
    "Name" = "tfeip"
  }
}