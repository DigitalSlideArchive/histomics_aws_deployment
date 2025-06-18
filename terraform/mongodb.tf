resource "aws_security_group" "mongo_sg" {
  name = "mongo-sg"

  ingress {
    from_port       = 27017 # can't use `aws_docdb_cluster.histomics.port` as it would create a cycle
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [aws_security_group.histomics_worker_sg.id, aws_security_group.histomics_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "mongo_password" {
  length  = 20
  special = false # So we don't have to urlencode this further down
}

resource "aws_docdb_cluster" "histomics" {
  cluster_identifier           = "histomics"
  engine_version               = "5.0.0"
  master_username              = "histomics"
  master_password              = random_password.mongo_password.result
  backup_retention_period      = 5
  preferred_backup_window      = "07:00-09:00"         # this is in UTC
  preferred_maintenance_window = "wed:05:00-wed:07:00" # this is in UTC
  vpc_security_group_ids       = [aws_security_group.mongo_sg.id]
}

resource "aws_docdb_cluster_instance" "histomics" {
  count              = 1
  identifier         = "histomics-cluster-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.histomics.id
  instance_class     = "db.r6g.large"
}

locals {
  mongodb_uri = "mongodb://histomics:${random_password.mongo_password.result}@${aws_docdb_cluster.histomics.endpoint}:${aws_docdb_cluster.histomics.port}/girder?tls=true&tlsInsecure=true&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false"
}
