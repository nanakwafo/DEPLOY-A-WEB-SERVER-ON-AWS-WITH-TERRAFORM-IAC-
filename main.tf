#--------------------------------------------------------------------
#---------------------------ENVIRONMENT------------------------------
#--------------------------------------------------------------------
# Terraform Version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA3OVUE2E4P6QXS5GO"
  secret_key = "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"
}
variable "subnet_prefix" {
  description = "cidr block for the subnet"
  type = string
}

#--------------------------------------------------------------------
#---------------------------INSTRUCTIONS-----------------------------
#--------------------------------------------------------------------
#1. Create vpc
#2. Create Internet Gateway
#3. Create Custom Route Table
#4. Create a Subnet
#5. Associate subnet with Route Table
#6. Create Security Group to allow port 22,80,443
#7. Create a network Interface with an ip in the subnet that was created in step4
#8. Assign an elastic IP to the network interface created in step 7
#9. Create Ubuntu Server and install/enable apache2
#--------------------------------------------------------------------------------
#--------------------STEP 1 (Create a VPC)---------------------------------------
#--------------------------------------------------------------------------------
# Create a VPC
resource "aws_vpc" "production_VPC" {
  cidr_block = "10.0.0.0/16"
}
#--------------------------------------------------------------------------------
#--------------------STEP 2 (Create a Internet Gateway)--------------------------
#--------------------------------------------------------------------------------
#Create Internet Gateway
resource "aws_internet_gateway" "production_GATEWAY" {
  vpc_id = aws_vpc.production_VPC.id
}
#--------------------------------------------------------------------------------
#--------------------STEP 3 (Create Custom Route Table)--------------------------
#--------------------------------------------------------------------------------
#Create Custom Route Table
resource "aws_route_table" "production_ROUTETABLE" {
  vpc_id = aws_vpc.production_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production_GATEWAY.id
  }
}
#--------------------------------------------------------------------------------
#--------------------STEP 4 (Create Subnet)--------------------------------------
#--------------------------------------------------------------------------------
# Create a Subnet
resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.production_VPC.id
  cidr_block = var.subnet_prefix
  availability_zone = "us-east-1a"

}
#--------------------------------------------------------------------------------
#--------------------STEP 5 (Associate subnet with Route Table)------------------
#--------------------------------------------------------------------------------
# Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.production_ROUTETABLE.id
}
#--------------------------------------------------------------------------------
#--------------------STEP 6 (Create Security Group to allow port 22,80,443)------
#--------------------------------------------------------------------------------
#Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_WEB" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.production_VPC.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_web"
  }
}
#--------------------------------------------------------------------------------------------------------------
#--------------------STEP 7 Create a network Interface with an ip in the subnet that was created in step4------
#--------------------------------------------------------------------------------------------------------------
#Create a network Interface with an ip in the subnet that was created in step4
resource "aws_network_interface" "webserver_NIC" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_WEB.id]
}
#--------------------------------------------------------------------------------------------------------------
#--------------------STEP 8 Assign an elastic IP to the network interface created in step 7--------------------
#--------------------------------------------------------------------------------------------------------------
#Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "production_ELASTICIP" {
  vpc                       = true
  network_interface         = aws_network_interface.webserver_NIC.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.production_GATEWAY]
}
#--------------------------------------------------------------------------------------------------------------
#--------------------STEP 9 Create Ubuntu Server and install/enable apache2--------------------
#--------------------------------------------------------------------------------------------------------------
#Create a EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-042e8287309f5df03"
  instance_type = "t2.micro"  
  availability_zone = "us-east-1a"
  key_name        = "main-key"
  
  network_interface  {
        device_index = 0
        network_interface_id = aws_network_interface.webserver_NIC.id
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'
              EOF
  tags = {
    Name = "Web-Server"
  }


}
