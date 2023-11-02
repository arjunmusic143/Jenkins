terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }
  }
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIATZZ42LX3GC63DJ4L"
  secret_key = "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"
}

resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}
resource "aws_subnet" "pub1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub1"
  }
}
resource "aws_subnet" "pub2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub2"
  }
}
resource "aws_subnet" "pvt1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.3.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "pvt1"
  }
}
resource "aws_subnet" "pvt2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.4.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "pvt2"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_eip" "eip" {


}

resource "aws_nat_gateway" "nat-int" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub1.id

  tags = {
    Name = "myint"
  }
}
resource "aws_route_table" "pub" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "pub-rt"
  }

}

resource "aws_route_table" "pvt" {


  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-int.id
    
  }

  tags = {
    Name = "pvt-rt"
  }

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pvt1.id
  route_table_id = aws_route_table.pvt.id
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.pub.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.pvt2.id
  route_table_id = aws_route_table.pvt.id
}


resource "aws_security_group" "allow-all" {

  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "sg-all"
  }
}
resource "aws_instance" "web" {
  ami           = "ami-05c0f5389589545b7"
  instance_type = "t3.medium"
  key_name = "my_keys"
  subnet_id = aws_subnet.pub1.id
  vpc_security_group_ids = [aws_security_group.allow-all.id]
  
  
  user_data = file("sh.sh")

  tags = {
    Name = "Jenkinserver"
  }
}
resource "aws_eip" "eip1" {


}
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.eip1.id
}
resource "aws_instance" "web2" {
  ami           = "ami-05c0f5389589545b7"
  instance_type = "t3.medium"
  key_name = "my_keys"
  subnet_id = aws_subnet.pub1.id
  vpc_security_group_ids = [aws_security_group.allow-all.id]
  
  
  user_data = file("sh1.sh")

  tags = {
    Name = "Jenkinserver-work"
  }
}
