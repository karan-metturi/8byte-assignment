output "vpc_id" {
  value = aws_vpc.karan_vpc.id
}

output "public_subnets" {
  value = [
    aws_subnet.karan_public_1.id,
    aws_subnet.karan_public_2.id
  ]
}

output "private_subnets" {
  value = [
    aws_subnet.karan_private_1.id,
    aws_subnet.karan_private_2.id
  ]
}

output "alb_sg_id" {
  value = aws_security_group.karan_alb_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.karan_ecs_sg.id
}

output "db_sg_id" {
  value = aws_security_group.karan_db_sg.id
}

output "db_endpoint" {
  value = aws_db_instance.karan_db.address
}
