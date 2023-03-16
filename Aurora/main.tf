data "aws_security_group" "ec2sg" {
  name = "${var.company}-ec2sg-${var.env}-web-apne2"
}

resource "aws_security_group" "rdssg" {
  name = "${var.company}-rdssg-${var.env}-mysql-apne2"
  tags = {
    Name = "${var.company}-rdssg-${var.env}-mysql-apne2"
  }
  vpc_id = var.vpc_id

  ingress {
    to_port = 3306
    from_port = 3306
    protocol = "tcp"
    security_groups = [ data.aws_security_group.ec2sg.id ]
  }

  ingress {
    to_port = 0
    from_port = 0
    protocol = "tcp"
    self = true
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

data "aws_secretsmanager_secret" "my_secret" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "my_secret" {
  secret_id = data.aws_secretsmanager_secret.my_secret.id
}

locals {
  my_secrets = jsondecode(data.aws_secretsmanager_secret_version.my_secret.secret_string)
}

resource "aws_db_parameter_group" "dbparam" {
  name = "${var.company}-dparam-${var.env}-mysql-apne2"
  family = "aurora-mysql5.7"

  tags = {
    Name = "${var.company}-dparam-${var.env}-mysql-apne2"
  }
}

resource "aws_db_subnet_group" "rds_subnets" {
  name = "${var.company}-sub-${var.env}-rds-apne2"
  subnet_ids = var.subnets
}

resource "aws_rds_cluster" "rds" {
  cluster_identifier      = "${var.company}-rds-${var.env}-mysql-apne2"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.1"
  db_subnet_group_name = aws_db_subnet_group.rds_subnets.name
  database_name           = local.my_secrets.dbname
  master_username         = local.my_secrets.username
  master_password         = local.my_secrets.password
#   database_name = var.dbname
#   master_username = var.username
#   master_password = var.password
  skip_final_snapshot = true
  vpc_security_group_ids = [ aws_security_group.rdssg.id ]

  tags = {
    Name = "${var.company}-rds-${var.env}-mysql-apne2"
  }
}

resource "aws_rds_cluster_instance" "rdsinst" {
  count = 2
  identifier = "${var.company}-rdsinst-${var.env}-mysql${count.index}-apne2"
  cluster_identifier = aws_rds_cluster.rds.id
  instance_class = var.db_instance
  engine = aws_rds_cluster.rds.engine
  engine_version = aws_rds_cluster.rds.engine_version
  db_subnet_group_name = aws_db_subnet_group.rds_subnets.name
}
# secret manager를 업데이트 하기 위해서는 그냥 추가하는건 안되는듯 하고 새로 만들어야 되는듯 하다. 때문에 기존값들과 새로운 값을 합쳐서 추가해준다.
resource "aws_secretsmanager_secret_version" "my_secret2" {
  secret_id = data.aws_secretsmanager_secret.my_secret.id
  secret_string = jsonencode(merge(local.my_secrets, {host = aws_rds_cluster.rds.endpoint}))
}