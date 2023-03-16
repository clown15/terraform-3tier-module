variable "company" {
    type = string
}
variable "env" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "vpc_cidr" {
    type = string
}
variable "pub_sub_ids" {
    type = list(string)
}
variable "domain" {
    type = string
}