data "aws_iam_policy" "amazon_ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

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
