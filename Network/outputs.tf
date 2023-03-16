output "vpc_id" {
  value = aws_vpc.burning-vpc.id
}
output "pri_web_rtb_id" {
  value = aws_route_table.rt_web_pri.id
}
output "web_sub_ids" {
  value = aws_subnet.pri_sub.*.id
}
output "pub_sub_ids" {
  value = aws_subnet.pub_sub.*.id
}
output "db_sub_ids" {
  value = aws_subnet.db_sub.*.id
}