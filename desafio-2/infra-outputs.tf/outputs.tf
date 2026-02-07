output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "s3_bucket" {
  value = aws_s3_bucket.backup.bucket
}
