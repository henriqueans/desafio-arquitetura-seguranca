# Desafio 02 – Infraestrutura AWS com IaC (Arquivo Único)

Este documento contém **toda a solução completa**, de forma simples e direta, focada no essencial que o desafio pede.  
Aqui você encontrará:

- Explicação da arquitetura
- Todo o código Terraform em um único `main.tf`
- Scripts utilizados no servidor web
- Passo a passo para criar e destruir o ambiente
- Premissas e decisões técnicas

---

# 1. Arquitetura (Resumo)

A solução cria um ambiente pequeno na AWS, dividido da seguinte forma:

- **VPC dedicada** com 1 subnet pública (bastion) e 2 privadas (web + RDS)
- **Bastion Host** para acesso SSH (apenas seu IP)
- **Web Server em subnet privada**, sem IP público, com Apache
- **RDS em subnet privada**, sem acesso público
- **Bucket S3** para backup das configs do Apache
- **Backup automático via script**
- **VPCE S3** para tráfego privado
- **Security Groups com mínimo privilégio**

A ideia é montar um ambiente funcional, seguro e simples — sem nada de recursos caros.

---

# 2. Código Terraform (arquivo único – `main.tf`)

> Basta criar um arquivo chamado:  
> **main.tf**  
> E colar tudo abaixo.

```hcl
#######################################
# Provider
#######################################
provider "aws" {
  region = "us-east-1"
}

#######################################
# Variáveis básicas
#######################################
variable "my_ip" {
  description = "Seu IP público para acessar o bastion"
  type        = string
}

variable "project" {
  default = "desafio-arq-sec"
}

#######################################
# VPC
#######################################
resource "aws_vpc" "main" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

#######################################
# Subnets
#######################################
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.2.0/24"
}

resource "aws_subnet" "private_b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.10.3.0/24"
}

#######################################
# Route Table Pública
#######################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#######################################
# Security Groups
#######################################

# Bastion
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Web
resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "ALB → WEB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

#######################################
# Bastion Host
#######################################
resource "aws_instance" "bastion" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "${var.project}-bastion"
  }
}

#######################################
# Web Server (Apache)
#######################################
resource "aws_instance" "web" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = false

  user_data = file("scripts/web-config.sh")

  tags = {
    Name = "${var.project}-web"
  }
}

#######################################
# S3 Bucket para Backup
#######################################
resource "aws_s3_bucket" "backup" {
  bucket        = "${var.project}-backup-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "backup_block" {
  bucket = aws_s3_bucket.backup.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

#######################################
# VPCE S3
#######################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [aws_route_table.public.id]
}

#######################################
# Bucket Policy restrita ao VPCE
#######################################
resource "aws_s3_bucket_policy" "backup_policy" {
  bucket = aws_s3_bucket.backup.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:*",
    "Resource": [
      "arn:aws:s3:::${var.project}-backup-bucket",
      "arn:aws:s3:::${var.project}-backup-bucket/*"
    ],
    "Condition": {
      "StringEquals": {
        "aws:sourceVpce": "${aws_vpc_endpoint.s3.id}"
      }
    }
  }]
}
EOF
}

#######################################
# RDS MySQL
#######################################
resource "aws_db_instance" "rds" {
  identifier                = "${var.project}-rds"
  engine                    = "mysql"
  instance_class            = "db.t3.micro"
  allocated_storage         = 20
  username                  = "admin"
  password                  = "SenhaAdmin123!"
  skip_final_snapshot       = true
  publicly_accessible       = false
  vpc_security_group_ids    = [aws_security_group.rds_sg.id]
  db_subnet_group_name      = aws_db_subnet_group.rds_subnets.name
}

resource "aws_db_subnet_group" "rds_subnets" {
  name       = "${var.project}-subnets"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}
