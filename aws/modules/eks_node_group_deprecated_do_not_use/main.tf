### DEPRECATED - USE eks_node_group_v2 INSTEAD ###

locals {
  instance_tags = merge({
    "Name" : "${var.node_group_name}-instance",
    # Required by some scanners when checking if imdsv2 is enforced
    "imds" : "secure"
  }, var.default_tags)
  volume_tags = merge({
    "Name" : "${var.node_group_name}-volume"
  }, var.default_tags)
  asg_tags = merge({
    "Name" : "${var.node_group_name}-asg"
  }, var.default_tags)
}

# A launch template to ensure all instances created by the node group have the right tags
resource "aws_launch_template" "node-group-launch-template" {
  name = "${var.node_group_name}-launch-template"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 40
      volume_type           = "gp3"
      encrypted             = "true"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.instance_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.volume_tags
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
    # here hop limit is set to 2 because application load balancer controller pods require a hop limit of 2 when using
    # imds v2. Documentation: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/installation/#using-the-amazon-ec2-instance-metadata-server-version-2-imdsv2
    http_put_response_hop_limit = 2
  }
}

resource "aws_autoscaling_group_tag" "tag" {
  for_each               = local.asg_tags
  autoscaling_group_name = aws_eks_node_group.node_group.resources[0].autoscaling_groups[0].name
  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}

resource "aws_eks_node_group" "node_group" {
  node_group_name = var.node_group_name
  cluster_name    = var.cluster_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  lifecycle {
    # This rule will also prevent certain kinds of updates to the nodegroup
    # So we should treat this as a 1 time setup and provision enough resources
    prevent_destroy = true
  }
  launch_template {
    version = aws_launch_template.node-group-launch-template.latest_version
    id      = aws_launch_template.node-group-launch-template.id
  }
  labels = var.labels
  dynamic "taint" {
    for_each = toset(var.taints)
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
  force_update_version = true
}

output "node_group_name" {
  value = aws_eks_node_group.node_group.node_group_name
}
