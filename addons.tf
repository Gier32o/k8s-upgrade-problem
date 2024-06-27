resource "aws_eks_addon" "vpc" {
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_version
  cluster_name                = aws_eks_cluster.this.name
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    "env": {
      "ENABLE_POD_ENI": "true"
    },
    "init": {
      "env": {
        "DISABLE_TCP_EARLY_DEMUX": "true"
      }
    }
  })
}