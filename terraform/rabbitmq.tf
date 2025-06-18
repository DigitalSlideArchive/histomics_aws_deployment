resource "random_password" "mq_password" {
  length  = 20
  special = false # So we don't have to urlencode this further down
}

resource "aws_security_group" "mq_broker_sg" {
  name = "mq-broker-sg"

  ingress {
    from_port   = 5671
    to_port     = 5671
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
  }
}

resource "aws_mq_broker" "jobs_queue" {
  broker_name = "jobs_queue"

  engine_type                = "RabbitMQ"
  auto_minor_version_upgrade = true
  engine_version             = "3.13"
  host_instance_type         = "mq.t3.micro"
  security_groups            = [aws_security_group.mq_broker_sg.id]

  user {
    username = "histomics"
    password = random_password.mq_password.result
  }
}
