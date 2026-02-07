# Desafio 02 – Infraestrutura como Código (IaC) em AWS

Este projeto implementa:

- VPC com subnets privada e pública
- Servidor Web Apache em subnet privada (sem IP público)
- Bastion Host em subnet pública para acesso SSH
- RDS MySQL em subnet privada
- ALB + ASG em 2 AZs
- Hardening automatizado
- Backups para S3 via endpoint privado
- Segredos no Secrets Manager
- Recursos com criptografia KMS

---

infra/ → Terraform
scripts/ → Hardening, Apache, Backup
diagramas/ → PNG ou drawioinfra/ → Terraform
scripts/ → Hardening, Apache, Backup
diagramas/ → PNG ou drawio


---

## Como aplicar

```bash
cd infra
terraform init
terraform apply

---
## Como acessar

ssh -i sua_chave.pem ec2-user@IP_DO_BASTION
ssh ec2-user@WEB_PRIVATE_IP

------
## Como destruir

terraform destroy
------


---

# 📁 **scripts/hardening.sh**

```bash
#!/bin/bash
set -e

# Desabilitar serviços desnecessários
systemctl disable bluetooth || true

# Permissões básicas
chmod 700 /root

# auditd
yum install -y audit
systemctl enable auditd
systemctl start auditd

# logrotate
yum install -y logrotate

# umask seguro
echo "umask 027" >> /etc/profile



