locals {
  instance_tags = merge({
    "Name" : "${var.node_group_name}-instance",
    # Required by some scanners when checking if imdsv2 is enforced
    "imds" : "secure"
  }, var.default_tags)
  volume_tags = merge({
    "Name" : "${var.node_group_name}-volume"
    }, var.default_tags,
    # Our python nodegroup creation function (mistakenly) added an 'imds': 'secure' tag to the volume resources (it's
    # only needed for instances). So we have to set this for those groups so terraform doesn't detect any drift
  var._do_not_use_for_new_nodegroups_port_from_python_created_nodegroup ? { imds = "secure" } : {})
  asg_tags = merge({
    "Name" : "${var.node_group_name}-asg"
  }, var.default_tags)
}

# A launch template to ensure all instances created by the node group have the right tags
resource "aws_launch_template" "node_group_launch_template" {
  name = "${var.node_group_name}-launch-template"

  # We unfortunately have to do this because the nodegroups we used to create in python did it this way, and we can't
  # yet safely migrate all k8s workloads. Once we move to new nodegroups that use launch templates correctly, we can
  # remove this
  instance_type = var._do_not_use_for_new_nodegroups_port_from_python_created_nodegroup ? null : var.instance_type
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = var.disk_size_gi
      volume_type           = "gp3"
      encrypted             = "true"
    }
  }

  # The python-made nodegroups had their volume tag specs defined before their instance tag specs, but the
  # terraform-made groups had the opposite. So, we make the default behavior be: instance first, volume second. We
  # override this only for nodegroups that we had to import directly from python.
  tag_specifications {
    resource_type = var._do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs ? "volume" : "instance"
    tags          = var._do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs ? local.volume_tags : local.instance_tags
  }

  tag_specifications {
    resource_type = var._do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs ? "instance" : "volume"
    tags          = var._do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs ? local.instance_tags : local.volume_tags
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
    # Ensures tf never conflicts with the cluster autoscaler
    ignore_changes = [scaling_config[0].desired_size]
  }
  launch_template {
    version = aws_launch_template.node_group_launch_template.latest_version
    id      = aws_launch_template.node_group_launch_template.id
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
  # See comment on the `instance_type` field on the launch template above
  instance_types       = var._do_not_use_for_new_nodegroups_port_from_python_created_nodegroup ? [var.instance_type] : null
  force_update_version = true
}

output "node_group_name" {
  value = aws_eks_node_group.node_group.node_group_name
}
