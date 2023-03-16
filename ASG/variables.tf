variable "company" {
  type = string
  default = ""
}
variable "env" {
  type = string
  default = ""
}
variable "albsg_id" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "instance_type" {
  type = string
  default = "t3.medium"
}
variable "volume_type" {
  type = string
  default = "gp3"
}
variable "iam_role" {
}
variable "sub_ids" {
  type = list(string)
}
variable "alb_id" {
  type = string
}
variable "alb_tg" {
}