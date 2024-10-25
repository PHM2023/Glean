data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# TODO: replace this with the lb arn after it's generated from the k8s ingress resource as a variable
data "aws_lb" "glean_external_lb" {
  tags = {
    "ingress.k8s.aws/stack" = "default/glean-ingress"
  }
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

data "aws_lb" "dse_internal_lb" {
  name = local.dse_internal_lb_name
}