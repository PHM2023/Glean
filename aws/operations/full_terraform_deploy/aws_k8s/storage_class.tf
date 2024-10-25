# storage class needed by stateful sets that use persistent volume claims
locals {
  volume_tags = concat([for tag_key, tag_value in var.default_tags : "${tag_key}=${tag_value}"], ["Name=ebs-gp3-volume"])
}

resource "kubernetes_storage_class" "ebs_csi_storage_class" {
  storage_provisioner = "ebs.csi.aws.com"
  metadata {
    name = "ebs-storage-class"
  }
  parameters = merge({
    type : "gp3"
    fsType : "ext4"
    encrypted : "true"
    # https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/tagging.md#storageclass-tagging
  }, { for index, tag_str in local.volume_tags : "tagSpecification_${tostring(tonumber(index) + 1)}" => tag_str })
  reclaim_policy      = "Delete"
  volume_binding_mode = "WaitForFirstConsumer"
}
