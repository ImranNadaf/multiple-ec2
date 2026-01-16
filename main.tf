data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical, Ubuntu, 24.04, amd64 noble image
}
data "aws_vpc" "default" {
  default = true
}
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ec2_keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.ec2_key.public_key_openssh
}
resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = var.filename
  file_permission = "0400"
}
resource "aws_security_group" "ssh_sg" {
  name        = "allow-ssh"
  description = "Allow SSH access"
  vpc_id      = data.aws_vpc.default.id
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
    Name = "ssh-sg"
  }
}
resource "aws_instance" "ec2" {
  count         = var.instance_count
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2_keypair.key_name
  tags = {
    Name = "ec2_${count.index + 1}"
  }
}