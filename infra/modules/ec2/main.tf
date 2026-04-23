
# Generate SSH key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.root}/${aws_key_pair.generated.key_name}.pem"
  file_permission = "0600"
}

# Security Group
resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name}"
}

# SSH
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# App Port
resource "aws_vpc_security_group_ingress_rule" "app" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.app_port
  to_port           = var.app_port
  ip_protocol       = "tcp"
}

# Jenkins Port
resource "aws_vpc_security_group_ingress_rule" "jenkins" {
  count             = var.enable_jenkins ? 1 : 0
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

# Allow all outbound
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# EC2 Instance
resource "aws_instance" "this" {
  ami                    = "ami-0442403fb8d244144"  
  instance_type          = "t3.medium"              
  key_name               = aws_key_pair.generated.key_name
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = var.name
    Role = var.name
  }
}