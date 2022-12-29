resource "aws_key_pair" "scriptkey" {
  key_name   = "scriptkey"
  public_key = file("scriptkey.pub")

}

resource "aws_instance" "varinstance" {
  ami           = var.AMIS[var.REGION]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.scriptkey.key_name

  tags = {
    "Name" = "varinstance"
  }
}

