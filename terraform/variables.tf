variable "vpc_cidr" {
  default = "10.18.0.0/16"
}

variable "public_subnets" {
  default = ["10.18.0.0/24", "10.18.2.0/24", "10.18.6.0/24"]
}

variable "private_subnets" {
  default = ["10.18.208.0/20", "10.18.224.0/20", "10.18.240.0/20"]
}
