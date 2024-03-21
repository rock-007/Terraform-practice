terraform {
  // this required provider will downolaed the required provider when
  // later can bew used to cinfgiure provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
//aws here is local name, can be anything but prefered aws for aws provider
# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "var.TF_VAR_ACCESS_KEY"
  secret_key = "var.TF_VAR_SECRET_KEY"
}



# Create a VPC
#VPC runs in a single region across multiple availabilty zones.
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = "Main VPC"
  }
}

#Create a subnet
resource "aws_subnet" "web" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.web_subnet // this is mandatory
    availability_zone = var.subnet_zone
    tags = {
        Name = "Web subnet"
    }
}

resource "aws_internet_gateway" "my_web_igw"{
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.main_vpc_name} IGW"
  }
}

resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route{
    cidr_block = "0.0.0.0/0"  // any destination traffic thats not destined inside VPX will be handeled here
    gateway_id =  aws_internet_gateway.my_web_igw.id
  }
  tags = {
    "Name" = "my-default-rt"
  }

}

resource "aws_default_security_group" "default_sec_group" {

  vpc_id = aws_vpc.main.id
  //ingress to define rules for ssh and http traffic
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
   cidr_blocks = [var.my_public_ip] // its list thats why []
  }
    ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // any ip address to come in
   
  }
  # f0r above two we dont need to define egress rules as security group is stateful
  # below is egress rule for the traffic that is generated from the insstance within the VPC

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"  // any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "Default security group"
  }


}
  resource "aws_instance"  "my_vm" {

    ami = "ami-02d7fd1c2af6eead0"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.web.id // this will force the ec2 isntace to be created in the VPC subnet
    vpc_security_group_ids = [aws_default_security_group.default_sec_group.id] // this will help to get external access to the ec2 instance
    associate_public_ip_address = true
    key_name = "production_ssh_key"  // it telling it to copy the public key of th pair called productionsshkey on the server in a specific directroy whe nit creates the instace.
  //if you change the tag in future the resource will not be created in the ftuure
    tags = {
      "Name" = "My Ec2 Instance - Amazon linux 2"
    }

  }
