#!/bin/bash

tar -czf /tmp/apache-config.tar.gz /etc/httpd/

aws s3 cp /tmp/apache-config.tar.gz s3://desafio-arq-sec-backup-bucket/
