variable "instance_count" {
  default = 3
}

variable "key_pair" {
  default = "First"
}

variable "vpc_id" {
  default = "vpc-0105a018741ce6222"
}

variable "subnet_id" {
  default = ["subnet-09fede41526683b9d", "subnet-04dead95da954d726"]
  type = list
}

variable "instance_type" {
  default = "t2.micro"
}

variable "filename" {
  default = "/home/vagrant/terraform/host-inventory"
}

variable "domain_name" {
  default = "oliyidetoyyib.me"
  type = string
  description = "Domain name"
}

variable "hosted_zone_id" {
  type = string
  default = "Z0423587BTKJPZFYX0RX"
  description = "Hosted zone id"
}

