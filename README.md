# Installing GitLab on Amazon ECS by Terraform

## Requirements

* Terraform
* AWS CLI

## Setup

### Clone this repo

```sh
$ git clone https://github.com/boiyaa/gitlab-ecs-terraform.git
$ cd gitlab-ecs-terraform
```

### Generate SSH key `devtools-key` to current directory

```sh
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/you/.ssh/id_rsa): devtools-key
```

### Set AWS credentials

```sh
$ export AWS_ACCESS_KEY_ID=your key
$ export AWS_SECRET_ACCESS_KEY=your secret
$ export AWS_DEFAULT_REGION=us-east-1
```

### Confirm `variables.tf`

### Intialize Terraform

```sh
$ terraform init
```

### Confirm the execution plan to AWS

```sh
$ terraform plan --out terraform.tfplan
```

### Execute plan

```sh
$ terraform apply terraform.tfplan
```

### Register GitLab Runner to GitLab

Get runner registering command and copy it

```sh
$ terraform output gitlab_runner_register
```

Start bastion instance and log in

```sh
$ aws ec2 start-instances --instance-ids `terraform output bastion_id`
$ ssh -i devtools-key ec2-user@`terraform output bastion_ip`
```

Run the runner registering command and log out

```sh
$ docker run ...
$ exit
```

Stop bastion instance

```sh
$ aws ec2 stop-instances --instance-ids `terraform output bastion_id`
```

## Operations

### Getting bastion IP

```sh
$ terraform output bastion_ip
```

### Getting bastion instance id

```sh
$ terraform output bastion_id
```

### Checking bastion instance status

```sh
$ aws ec2 describe-instance-status --instance-id `terraform output bastion_id` --query "InstanceStatuses[].InstanceState.Name" --output text
```

### Getting ecs instance IPs

```sh
$ aws ec2 describe-instances --filters "Name=tag:Name,Values=devtools-instance-ecs" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[PrivateIpAddress]" --output text
```

### Logging in ecs instance 0

```sh
$ ssh -i devtools-key ec2-user@`aws ec2 describe-instances --filters "Name=tag:Name,Values=devtools-instance-ecs" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].[PrivateIpAddress][0]" --output text` -o 'ProxyCommand ssh -i devtools-key -W %h:%p ec2-user@`terraform output bastion_ip`'
```

Run after starting bastion instance

### Unregistering GitLab Runner from GitLab

Get runner unregistering command and copy it

```sh
$ terraform output gitlab_runner_unregister
```

Log in bastion and run the runner unregistering command

### Backing up GitLab

Log in ecs instance that has GitLab container

Run the following command

```sh
$ docker exec -t `docker ps --filter ancestor=gitlab/gitlab-ce:10.2.4-ce.0 --format {{.Names}}` gitlab-rake gitlab:backup:create
```

Reference: [Creating backups for GitLab instances in Docker containers](https://docs.gitlab.com/omnibus/settings/backups.html#creating-backups-for-gitlab-instances-in-docker-containers)

### Restoring GitLab

Log in ecs instance that has GitLab container

Run the following commands

```sh
$ docker exec -t `docker ps --filter ancestor=gitlab/gitlab-ce:10.2.4-ce.0 --format {{.Names}}` gitlab-ctl stop unicorn
$ docker exec -t `docker ps --filter ancestor=gitlab/gitlab-ce:10.2.4-ce.0 --format {{.Names}}` gitlab-ctl stop sidekiq
$ docker exec -it `docker ps --filter ancestor=gitlab/gitlab-ce:10.2.4-ce.0 --format {{.Names}}` gitlab-rake gitlab:backup:restore BACKUP=1510107973_2017_11_08_10.1.1
$ docker exec -t `docker ps --filter ancestor=gitlab/gitlab-ce:10.2.4-ce.0 --format {{.Names}}` gitlab-ctl restart
$ docker exec -t `docker ps --filter ancestor=gitlab/gitlab-ce:10.2.4-ce.0 --format {{.Names}}` gitlab-rake gitlab:check SANITIZE=true
```

Reference: [Restore for Omnibus installations](https://docs.gitlab.com/ce/raketasks/backup_restore.html#restore-for-omnibus-installations)
