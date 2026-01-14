variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "parvezonline"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "domain_name" {
  type    = string
  default = "parvezonline.com"
}

variable "instance_name" {
  type    = string
  default = "parvezonline-dev-k3s-01"
}

variable "instance_type" {
  type    = string
  default = "t3.large"
}

variable "volume_size_gb" {
  type    = number
  default = 100
}

variable "key_name" {
  type    = string
  default = "parvezonline-key"
}

variable "ssh_allowed_cidr" {
  type = string
}
