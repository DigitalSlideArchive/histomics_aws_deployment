resource "random_password" "redis_password" {
  length  = 20
  special = false
}

resource "aws_elasticache_user" "histomics" {
  user_id       = "histomics"
  user_name     = "default"
  access_string = "on ~* +@all"
  engine        = "REDIS"
  passwords     = [random_password.redis_password.result]
}

resource "aws_elasticache_user_group" "histomics" {
  user_group_id   = "histomics"
  engine          = "REDIS"
  user_ids        = [aws_elasticache_user.histomics.user_id]
}

resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Allow Redis access"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "histomics"
  description                   = "Histomics Redis"
  engine                        = "redis"
  engine_version                = "7.0"
  node_type                     = "cache.t3.micro"
  num_cache_clusters            = 1
  automatic_failover_enabled    = false

  user_group_ids                = [aws_elasticache_user_group.histomics.user_group_id]
  security_group_ids            = [aws_security_group.redis_sg.id]

  transit_encryption_enabled    = true
  at_rest_encryption_enabled    = true
}
