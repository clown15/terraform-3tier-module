variable "region" {
    type = string
}
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
variable "domain" {
    type = string
}
variable "bucket_name" {
    type = string
}
variable "secret_name" {
    type = string
}

############ DB variable ###########
variable "dbname" {
    type = string
}
variable "username" {
    type = string
}
variable "db_instance" {
    type = string
}