#!/bin/bash
BUCKET_NAME="${bucket_name}"

aws s3 cp /etc/httpd/conf/ s3://$BUCKET_NAME/configs/ --recursive
