output "albsg_id" {
  value = aws_security_group.alb_sg.id
}
output "alb_id" {
  value = aws_lb.web_alb.id
}
output "alb_tg" {
  value = aws_lb_target_group.instg
}
output "alb" {
  value = aws_lb.web_alb
}