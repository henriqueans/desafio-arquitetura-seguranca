variable "region" {
  default = "us-east-1"
}

variable "allowed_ssh" {
  description = "IP permitido no Bastion"
}

variable "db_password" {
  sensitive = true
}
