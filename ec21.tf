provider "aws" {
  # I am using Virginia region
  region = "us-east-1"
}
resource "aws_instance" "testing" {
  ami           = "ami-05fa00d4c63e32376"
  instance_type = "t2.micro"
  key_name      = "terraformkey"
  tags = {
    Name = "testing"
  }

}