variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(object({
    name = string
    zone = string
    cidr = string
    map_public_ip_on_launch = bool
  }))
}