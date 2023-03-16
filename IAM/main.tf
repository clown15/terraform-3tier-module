resource "aws_iam_policy" "SecretsManagerRead" {
  name        = "SecretsManagerRead"
  path        = "/"
  description = "SecretsManagerRead"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "SecretsManagerRead",
        Effect : "Allow",
        Action : "secretsmanager:GetSecretValue",
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role" "ec2ssm" {
  name = "${var.company}-role-ec2ssm"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  tags = {
    name = "${var.company}-role-ec2ssm"
  }
}

resource "aws_iam_role_policy_attachment" "ec2ssm-SecretsManagerRead" {
  role       = aws_iam_role.ec2ssm.name
  policy_arn = aws_iam_policy.SecretsManagerRead.arn
}
# policy들 이름을 변수로 받아서 반복 처리 가능할까???
data "aws_iam_policy" "AmazonEC2RoleforSSM" {
  name = "AmazonEC2RoleforSSM"
}
resource "aws_iam_role_policy_attachment" "ec2ssm-AmazonEC2RoleforSSM" {
  role       = aws_iam_role.ec2ssm.name
  policy_arn = data.aws_iam_policy.AmazonEC2RoleforSSM.arn
}

data "aws_iam_policy" "AmazonS3FullAccess" {
  name = "AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "ec2ssm-AmazonS3FullAccess" {
  role       = aws_iam_role.ec2ssm.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}