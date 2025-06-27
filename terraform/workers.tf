resource "aws_security_group" "histomics_worker_sg" {
  name = "histomics-worker-sg"

  vpc_id = aws_default_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "worker" {
  name = "worker-instance-profile"
  role = aws_iam_role.ecs_task_execution_role.name
}

resource "aws_key_pair" "worker_ec2_ssh_key" {
  public_key = var.ssh_public_key
}

resource "aws_instance" "worker" {
  ami                    = var.worker_ami_id
  instance_type          = "t3.xlarge"
  count                  = 1
  vpc_security_group_ids = [aws_security_group.histomics_worker_sg.id]
  user_data              = <<EOF
#!/bin/bash
echo 'mount -t efs ${aws_efs_file_system.assetstore.id}:/ /assetstore' >> /etc/mount_assetstore.sh
echo 'GIRDER_WORKER_BROKER=amqps://histomics:${random_password.mq_password.result}@${aws_mq_broker.jobs_queue.id}.mq.${data.aws_region.current.region}.on.aws:5671' >> /etc/girder_worker.env
echo 'GIRDER_MONGO_URI=${local.mongodb_connection_string}' >> /etc/girder_worker.env
EOF
  subnet_id              = data.aws_subnets.default.ids[0]
  iam_instance_profile   = aws_iam_instance_profile.worker.name
  key_name               = aws_key_pair.worker_ec2_ssh_key.key_name

  root_block_device {
    volume_size = 256
  }
}
