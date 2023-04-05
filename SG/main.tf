resource "aws_security_group" "sg" {
  vpc_id      = var.vpc_id
  name        = var.sg_name
  description = var.sg_description

  tags = {
    Name = var.sg_name
  }

  dynamic "ingress" {
    for_each = var.ingresses
    content {
      description = ingress.key
      from_port   = lookup(ingress.value, "from_port", 0)
      to_port     = lookup(ingress.value, "to_port", 0)
      protocol    = lookup(ingress.value, "protocol", "-1")
      cidr_blocks = lookup(ingress.value, "cidr_blocks", ["0.0.0.0/0"])
    }
  }

  dynamic "egress" {
    for_each = var.egresses
    content {
      description = egress.key
      from_port   = lookup(egress.value, "from_port", 0)
      to_port     = lookup(egress.value, "to_port", 0)
      protocol    = lookup(egress.value, "protocol", "-1")
      cidr_blocks = lookup(egress.value, "cidr_blocks", ["0.0.0.0/0"])
    }
  }
}
