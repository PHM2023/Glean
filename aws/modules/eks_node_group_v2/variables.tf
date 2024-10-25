variable "node_group_name" {
  description = "The name of the node group"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "The ARN of the role to use for the node group worker"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet ID's to use for the node group"
  type        = list(string)
}

variable "default_tags" {
  description = "Tags that need to be associated with all resources by default"
  type        = map(string)
  default     = {}
}

variable "desired_size" {
  description = "Desired size of node group"
  type        = number
}

variable "min_size" {
  description = "Min size of node group"
  type        = number
}
variable "max_size" {
  description = "Max size of node group"
  type        = number
}

variable "labels" {
  description = "Labels to attach to the node group"
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "Taints to apply to the node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "disk_size_gi" {
  description = "Size of disk in GB"
  type        = number
  default     = 50
}

variable "instance_type" {
  description = "Machine type for the nodegroup"
  type        = string
  # It's important we set this default explicitly, since it gets propagated to the launch template specs.
  # If we left this as null on both the node group and the launch template, EKS will not let you change the
  # instance type later using the launch template, and we require launch template specs to be able to set
  # default instance/volume tags.


  default = "t3.medium"
}

# TODO: migrate existing workloads to new nodegroups and remove these next two
variable "_do_not_use_for_new_nodegroups_port_from_python_created_nodegroup" {
  # This is really annoying, but we used to create nodegroups in both terraform and python. The python-made nodegroups
  # had subtle differences with the terraform-created groups that we need to account for, otherwise terraform will
  # detect drift when trying to import the existing groups/launch templates, which can cause downtime for stateful
  # workloads.
  description = "DO NOT SET THIS FOR NEW NODEGROUPS: If true, tweaks nodegroup/launch template configs to fit nodegroups that used to be created in python"
  type        = bool
  default     = false
}

variable "_do_not_use_for_new_nodegroups_defined_volume_tag_specs_before_instance_tag_specs" {
  # Some of the python-made nodegroups had their volume tag specs defined before their instance tag specs, but the
  # terraform-made groups had the opposite. So we have to add in a special override for this for now, but we can
  # delete this once all the relevant nodegroups are fully managed by terraform
  description = "DO NOT SET THIS FOR NEW NODEGROUPS: If true, defines the volume tag specs before the instance specs"
  type        = bool
  default     = false
}