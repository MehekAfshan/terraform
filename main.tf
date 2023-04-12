terraform{
  backend "s3" {
    bucket = "mehekbucket"
    region = "ap-south-1"
    key = "terraform.tfstate"

  }
}
 
 
 provider "aws" {
  region = "ap-south-1"
  

}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.vpc.id
  availability_zone = "ap-south-1a"  
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Subnet"
  }
}

resource "aws_security_group" "sample-test" {
  name_prefix = "sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security Group"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gateway"
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "route"
  }
}

 resource "aws_route_table_association" "subnet" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.route.id
}

resource "aws_instance" "ec2" {
  ami           = "ami-07d3a50bd29811cd1"
  instance_type = "t2.micro"
  key_name      = "mehek-25"
  count = "1"
  vpc_security_group_ids = ["${aws_security_group.sample-test.id}"]
  subnet_id = aws_subnet.publicsubnet.id
  associate_public_ip_address = true
  tags = {
    Name = "ec2"
  }
}