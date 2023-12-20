# Creating VPC

resource "aws_vpc" "mumbai-vpc" {
  cidr_block = "10.10.0.0/16"

  instance_tenancy = "default"

  tags = {
    Name = "MUMBAI-VPC"
  }
}


# Creating Subnet

resource "aws_subnet" "mumbai-subnet-1a" {
  vpc_id                  = aws_vpc.mumbai-vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-MUMBAI-SUBNET-1A"
  }
}

resource "aws_subnet" "mumbai-subnet-1b" {
  vpc_id                  = aws_vpc.mumbai-vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-MUMBAI-SUBNET-1B"
  }
}

resource "aws_subnet" "mumbai-subnet-1c" {
  vpc_id            = aws_vpc.mumbai-vpc.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "ap-south-1c"

  tags = {
    Name = "Private-MUMBAI-SUBNET-1C"
  }
}