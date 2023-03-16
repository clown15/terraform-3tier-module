variable "env" { 
    type = string
}
variable "vpc_cidr" { 
    type = string
}
variable "company" {
    type = string
}
variable "public_subnets" {
    type = list(object({
        name = string
        zone = string
        cidr = string
    }))
}
variable "private_subnets" {
    type = list(object({
        name = string
        zone = string
        cidr = string
    }))
}
variable "db_subnets" {
    type = list(object({
        name = string
        zone = string
        cidr = string
    }))
}