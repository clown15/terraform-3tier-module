variable "company" {
  type = string
}
variable "env" {
  type = string
}
variable "secret_name" {
  type = string
}
variable "vpc_id" {
  type = string
  default = ""
}
variable "subnets" {
  type = list(string)
}
variable "dbname" {
  type = string
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}
variable "db_instance" {
  type = string
}