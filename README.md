# Histomics AWS deployment scripts

This repository contains infrastructure-as-code for reproducible Histomics deployments on AWS
using highly managed, scalable services, including

* Elastic Container Service for the web application
* EC2 instances for celery worker nodes
* DocumentDB as the mongo-compatible database
* Amazon MQ as the celery queue
* CloudWatch for log persistence
* Sentry integration (optional)

### Prerequisites

1. Obtain a domain name via AWS Route53, and set the `domain_name` terraform variable to its value.
1. Create an SSH keypair and set the public key as the `ssh_public_key` terraform variable.
   This is the key that will be authorized on the worker EC2 instance(s).
1. Set AWS credentials in your shell environment.

### Building the worker AMI

1. `cd packer`
1. `packer build worker.pkr.hcl`
1. Use the resulting AMI ID as the `worker_ami_id` terraform variable.

### Deploying

1. `docker build -t zachmullen/histomics-load-test -f histomicsui.Dockerfile .`
1. `docker push zachmullen/histomics-load-test`
1. Copy the SHA from the docker push command and paste it into `main.tf`
1. From the terraform directory, run `terraform apply -var-file=.tfvars`
