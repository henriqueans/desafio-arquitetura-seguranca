#!/bin/bash
set -e

yum update -y
yum install -y httpd

systemctl enable httpd
systemctl start httpd

echo "<h1>Servidor Apache - Desafio 02</h1>" > /var/www/html/index.html
