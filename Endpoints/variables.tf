variable "company" {
    type = string
}
variable "env" {
    type = string
}
variable "region" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "vpc_cidr" {
    type = string
}
variable "pri_web_rtb_id" {
    type = string
}
variable "pub_sub_ids" {
    type = list(string)
}