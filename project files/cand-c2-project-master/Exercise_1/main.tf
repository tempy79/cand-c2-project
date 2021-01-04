# TODO: Designate a cloud provider, region, and credentials

provider "aws" {
  access_key = "AKIAJPF7S4WDE6Z2SBGA"
  secret_key = "z2HnHWwsp/LSa7a61ky1BGkaRLvsUN2BubcznVhM"
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
