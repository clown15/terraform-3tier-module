variable "vpc_id" {
  type = string
}
variable "sg_name" {
  type = string
}
variable "sg_description" {
  type    = string
  default = "None"
}

variable "ingresses" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
variable "egresses" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}
