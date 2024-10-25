# The lifecycle is required because of an issue with Terraform not properly handling the deletion of rules properly.
# See: https://github.com/hashicorp/terraform-provider-aws/issues/17601

resource "aws_wafv2_ip_set" "central_ip_set" {
  ip_address_version = "IPV4"
  name               = "glean-central-ip-set"
  scope              = "REGIONAL"
  addresses          = local.glean_central_ip_set_addresses

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_wafv2_ip_set" "ip_redlist_set" {
  count              = length(var.ip_red_list) > 0 ? 1 : 0
  ip_address_version = "IPV4"
  name               = "glean-ip-redlist-set"
  scope              = "REGIONAL"
  addresses          = var.ip_red_list

  lifecycle {
    create_before_destroy = true
  }
}

# The green list in AWS must be a combination of the AWS NAT IP (cross-referenced from the network TF), and the list of provided
# green listed CIDR blocks:
resource "aws_wafv2_ip_set" "ip_greenlist_set" {
  count              = length(var.ip_green_list) > 0 ? 1 : 0
  ip_address_version = "IPV4"
  name               = "glean-ip-greenlist-set"
  scope              = "REGIONAL"
  addresses          = concat(["${var.nat_gateway_public_ip}/32"], var.ip_green_list)

  lifecycle {
    create_before_destroy = true
  }
}
