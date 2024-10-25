resource "aws_iam_policy" "ecr_fetch_policy" {
  name        = "ECRFetchPolicy"
  description = "ECR Get Auth Token Policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetDownloadUrlForLayer",
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "crawl_temp_bucket_reader_writer_policy" {
  name        = "CrawlTempBucketReaderWriterPolicy"
  description = "Read and write access to the crawl-temp bucket"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectAttributes",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.crawl_temp_bucket}/*"
        ]
      },
      {
        "Action" : [
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ],
        "Effect" : "Allow",
        "Resource" : var.crawl_temp_bucket_arn
      }
    ]
  })
}

resource "aws_iam_role" "git_crawler_iam_role" {
  name                 = "git-crawler-iam-role"
  permissions_boundary = var.iam_permissions_boundary_arn
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    data.aws_iam_policy.amazon_ssm_managed_instance_core.arn,
    var.cloud_watch_logs_policy_arn,
    var.config_bucket_reader_policy_arn,
    aws_iam_policy.crawl_temp_bucket_reader_writer_policy.arn,
    aws_iam_policy.ecr_fetch_policy.arn
  ]
}

resource "aws_iam_instance_profile" "git_crawler_iam_instance_profile" {
  name = "GitCrawlerIAMRoleProfile"
  role = aws_iam_role.git_crawler_iam_role.name
}

resource "aws_instance" "git_crawler" {
  ami = data.aws_ami.ubuntu.id

  instance_type = var.machine_type

  tags = {
    Name = "git_crawler"
  }

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }

  subnet_id              = var.git_crawler_subnet_id
  vpc_security_group_ids = [var.git_crawler_security_group]

  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.git_crawler_iam_instance_profile.name
  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    set -ex
    while [ ! -b /dev/nvme1n1 ]; do echo 'Waiting for /dev/nvme1n1 to attach' ; sleep 10 ; done
    sudo apt-get update
    sudo file -s /dev/nvme1n1 | grep "/dev/nvme1n1: data" && sudo mkfs -t xfs /dev/nvme1n1
    sudo mkdir -p /mnt/git_crawler/workspace
    sudo mount /dev/nvme1n1 /mnt/git_crawler/workspace
    sudo xfs_growfs /dev/nvme1n1
    sudo apt-get install -y docker.io
    sudo apt-get install unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo unzip awscliv2.zip
    sudo ./aws/install

    aws ecr get-login-password --region us-east-1 | sudo docker login --username AWS --password-stdin 518642952506.dkr.ecr.us-east-1.amazonaws.com
    sudo docker pull ${var.image_uri}
    sudo docker run -e AWS_ACCOUNT_ID=${var.account_id} -e AWS_REGION=${var.region} -d -p 8080:8080 ${var.image_uri}
  EOF

  lifecycle {
    # We don't want updates to the latest ubuntu ami to trigger an update
    ignore_changes = [ami]
  }
}

resource "aws_ebs_volume" "disk" {
  availability_zone = var.availability_zone
  size              = var.disk_size
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "data-git-crawler"
  }
}

resource "aws_volume_attachment" "git_crawler_ebs_attachment" {
  device_name = "/dev/sdf"

  volume_id   = aws_ebs_volume.disk.id
  instance_id = aws_instance.git_crawler.id
  # Setting both of these to address some flakes when detaching the volume
  stop_instance_before_detaching = true
  force_detach                   = true
}
