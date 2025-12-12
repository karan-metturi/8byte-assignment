resource "aws_db_subnet_group" "karan_db_subnets" {
  name = "karan-db-subnet-group"
  subnet_ids = [
    aws_subnet.karan_private_1.id,
    aws_subnet.karan_private_2.id
  ]

  tags = {
    Name = "karan-db-subnet-group"
  }
}

resource "aws_db_instance" "karan_db" {
  identifier          = "karan-postgres-db"
  allocated_storage   = 20
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro"
  db_name             = "appdb"
  username            = "postgres"
  password            = var.db_password
  port                = 5432
  publicly_accessible = false
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.karan_db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.karan_db_subnets.name

  tags = {
    Name = "karan-rds"
  }
}
