#!/bin/bash

yum update -y
yum install -y httpd

echo "<h1>Hello World - Apache</h1>" > /var/www/html/index.html

systemctl enable httpd
systemctl start httpd
