locals {
  # Hostname will look something like
  # k8s-default-dseinter-c0d1d04854-2fe235026a10439b.elb.us-east-1.amazonaws.com
  # whereas the load balancer name is only: k8s-default-dseinter-c0d1d04854
  dse_internal_lb_hostname_split_by_dot  = split(".", var.dse_internal_lb_hostname)
  dse_internal_lb_hostname_split_by_dash = split("-", local.dse_internal_lb_hostname_split_by_dot[0])
  dse_internal_lb_name                   = join("-", slice(local.dse_internal_lb_hostname_split_by_dash, 0, length(local.dse_internal_lb_hostname_split_by_dash) - 1))
}
