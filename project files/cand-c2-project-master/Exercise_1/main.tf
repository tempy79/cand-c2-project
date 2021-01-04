# TODO: Designate a cloud provider, region, and credentials

provider "aws" {
  region = "us-east-1"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2

resource "aws_instance" "example" {
  ami = "ami-0c6b1d09930fac512"
  instance_type = "t2.micro"
  tags = {
    Name = "MyEC2micro"
  }
  count = 4
}
