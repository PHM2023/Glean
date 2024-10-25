data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_role" "bastion" {
  name                 = "bastion"
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
  managed_policy_arns = [data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "bastion"
  role = aws_iam_role.bastion.name
}

# Uses the most recent ubuntu-focal-20.04-amd64-server image
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    # Pinning this AMI version for now to avoid a OpenSSH CVE:
    # https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2024-6387
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20240614"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami = data.aws_ami.ubuntu.id

  # The equivalent of GCP e2-small
  instance_type = var.bastion_instance_type

  root_block_device {
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "bastion"
  }

  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  subnet_id = var.subnet_id

  vpc_security_group_ids = [var.bastion_security_group]

  # Ensures if the user data changes we reboot the instance completely
  user_data_replace_on_change = true

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }

  user_data = <<-EOF
    #!/bin/bash
    set -ex

    # Install session manager agent for remote access:
    # https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu-64-snap.html
    sudo snap install amazon-ssm-agent --classic
    sudo snap start amazon-ssm-agent

    sudo apt-get update && sudo apt-get install -y tinyproxy
    echo "Allow localhost" >> /etc/tinyproxy/tinyproxy.conf
    # Bump tinyproxy connection limits to support a full terraform apply with the kubernetes provider
    sudo sed -i -e "s|MaxClients .*|MaxClients 3000|"  \
           -e "s|MinSpareServers .*|MinSpareServers 200|" \
           -e "s|MaxSpareServers .*|MaxSpareServers 3000|" \
           -e "s|StartServers .*|StartServers 2000|" \
           /etc/tinyproxy/tinyproxy.conf

    sudo service tinyproxy restart

  EOF

  lifecycle {
    # We don't want updates to the latest ubuntu ami to trigger an update
    ignore_changes = [ami]
  }

}


resource "null_resource" "ssm_readiness_check" {

  provisioner "local-exec" {
    command = "/bin/bash ${path.module}/wait_for_bastion.sh ${var.region} ${aws_instance.bastion.id}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_bastion_ingress_allow" {
  security_group_id            = var.eks_cluster_security_group_id
  description                  = "For allowing bastion instance connections"
  referenced_security_group_id = var.bastion_security_group
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

