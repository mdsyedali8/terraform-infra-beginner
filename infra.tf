

# resource "aws_instance" "web" {
#   ami           = "ami-0287a05f0ef0e9d9a"
#   instance_type = "t2.micro"
#   key_name   = "linux-os-key"


#   tags = {
#     Name = "Machine_tag_manual"
#   }
# }

# resource "aws_eip" "eip_instance" {
#   instance = aws_instance.web.id

# }

#Creating EC2 instance

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }


# Creating s3 backend
terraform {
  backend "s3" {
    bucket = "terraform-state-7891"
    key    = "infra-state.tfstate"
    region = "ap-south-1"
  }
}




#Creating EC2 instance

resource "aws_instance" "mumbai-ec2" {
  ami                         = "ami-0bf068700c1c1cb9b" #"ami-0287a05f0ef0e9d9a"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.Mumbai-key.id
  subnet_id                   = aws_subnet.mumbai-subnet-1a.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.Mumbai-SG.id]


  tags = {
    Name = "Mumbai-EC2-machine"
  }
}


resource "aws_instance" "mumbai-ec2-2" {
  ami           = "ami-0bf068700c1c1cb9b" #"ami-0287a05f0ef0e9d9a"  
  instance_type = "t2.micro"
  key_name      = aws_key_pair.Mumbai-key.id
  subnet_id     = aws_subnet.mumbai-subnet-1b.id
  #associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.Mumbai-SG.id]

  tags = {
    Name = "Mumbai-EC2-machine-2"
  }
}


#Creating Key-Pair

resource "aws_key_pair" "Mumbai-key" {
  key_name   = "mumbai-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDMfTxsDD0PR9hySBcl+7PTdmaGB7lJ2k6hPYNKU1n8xm+l7NX9aGJebY9eekKKREk+xD6zH2iLkOzxxd/2GQYh7eejuckh0Z5vsG8UJ7Yl9sjznXCGRSVWJG6jZ2Efcx6/fkcZYrST/o+6wdu82CxYEsQwyW9DHvqyBjDNrhgZ3ktD75NHTjkJ7K5zh0fX2F0kvI1vT99nYUcTG4o/oiFTxeKqpjrNCrtPDfHCZhhyFobmFkZlyZeE6793YQ5PCrK6pOSvBxRTt66IHTXe2KqAoOQPZNrQTCWqDilnEiglG2UhbTvbFVqezfzFBGvX5gkJxVqV+bxbPK4E8h7kVzW6qFBUwsIJ1vrabXhsG11u7RLe7FtdgPj5FvuNkDXZ/lpW8oN9X7THiGHfWK9ma8M2jTmpOxeCh1Hx0kPwoUtoP9UrNBXDqhAuK9u9fP2C0u3kt+V4Dbbqs1uS8TCgIhtmp63PDB8yrbUoY3iG197UczybzlPSn+DwHASSOSt+Q+U= syedali@Syeds-MacBook-Air.local"
}

#Creating IGW

resource "aws_internet_gateway" "mumbai-IGW" {
  vpc_id = aws_vpc.mumbai-vpc.id

  tags = {
    Name = "Mumbai-IGW"
  }
}

#Creating Security group

resource "aws_security_group" "Mumbai-SG" {
  name        = "Mumbai-SG"
  description = "Allow 80 and 22 port as inbound"
  vpc_id      = aws_vpc.mumbai-vpc.id

  ingress {
    description = "22 from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.37.33.111/32", "0.0.0.0/0"]

  }

  ingress {
    description = "80 from outside"
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
    Name = "allow_80_22"
  }
}


#Create public route table

resource "aws_route_table" "Mumbai_public_RT" {
  vpc_id = aws_vpc.mumbai-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mumbai-IGW.id
  }

  tags = {
    Name = "Mumbai_public_RT"
  }
}

resource "aws_route_table_association" "subnet-1a-association" {
  subnet_id      = aws_subnet.mumbai-subnet-1a.id
  route_table_id = aws_route_table.Mumbai_public_RT.id
}

resource "aws_route_table_association" "subnet-1b-association" {
  subnet_id      = aws_subnet.mumbai-subnet-1b.id
  route_table_id = aws_route_table.Mumbai_public_RT.id
}

#Creating private RT

resource "aws_route_table" "Mumbai_private_RT" {
  vpc_id = aws_vpc.mumbai-vpc.id

  tags = {
    Name = "Mumbai_private_RT"
  }
}

resource "aws_route_table_association" "subnet-1c-association" {
  subnet_id      = aws_subnet.mumbai-subnet-1c.id
  route_table_id = aws_route_table.Mumbai_private_RT.id
}

#Create Load balancer

resource "aws_lb" "mumbai_lb" {
  name               = "Mumbai-webapp"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Mumbai-SG.id]
  subnets            = [aws_subnet.mumbai-subnet-1a.id, aws_subnet.mumbai-subnet-1b.id, aws_subnet.mumbai-subnet-1c.id]

  #enable_deletion_protection = false


  tags = {
    Environment = "production"
  }
}

#Create listener

resource "aws_lb_listener" "mumbai-listener" {
  load_balancer_arn = aws_lb.mumbai_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mumbai-target-group.arn
  }
}

#Creating target group

resource "aws_lb_target_group" "mumbai-target-group" {
  name     = "Mumbai-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mumbai-vpc.id
}

#Creating target group attachment

resource "aws_lb_target_group_attachment" "attach-1" {
  target_group_arn = aws_lb_target_group.mumbai-target-group.arn
  target_id        = aws_instance.mumbai-ec2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach-2" {
  target_group_arn = aws_lb_target_group.mumbai-target-group.arn
  target_id        = aws_instance.mumbai-ec2-2.id
  port             = 80
}


#Creating Launch template

resource "aws_launch_template" "mumnbai_launch_template" {
  name     = "Mumnbai_launch_template"
  image_id = "ami-0287a05f0ef0e9d9a"

  key_name = aws_key_pair.Mumbai-key.id

  vpc_security_group_ids = [aws_security_group.Mumbai-SG.id]
  instance_type          = "t2.micro"


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Mumbai-instance-via-ASG"
    }
  }

  user_data = filebase64("example.sh")
}

#Creating ASG

resource "aws_autoscaling_group" "mumbai_asg" {
  name                = "Mumbai_ASG"
  vpc_zone_identifier = [aws_subnet.mumbai-subnet-1a.id, aws_subnet.mumbai-subnet-1b.id]
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.mumbai-target-group-2.arn]

  launch_template {
    id      = aws_launch_template.mumnbai_launch_template.id
    version = "$Latest"
  }
}


#Create Load balancer 2

resource "aws_lb" "mumbai_lb_2" {
  name               = "Mumbai-webapp-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Mumbai-SG.id]
  subnets            = [aws_subnet.mumbai-subnet-1a.id, aws_subnet.mumbai-subnet-1b.id, aws_subnet.mumbai-subnet-1c.id]

  #enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

#Create listener 2

resource "aws_lb_listener" "mumbai-listener-2" {
  load_balancer_arn = aws_lb.mumbai_lb_2.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mumbai-target-group-2.arn
  }
}

#Creating target group 2

resource "aws_lb_target_group" "mumbai-target-group-2" {
  name     = "Mumbai-TG-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mumbai-vpc.id
}


# Creating S3 bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-state-7891"

  tags = {
    Name = "Devops_training"
  }
}



