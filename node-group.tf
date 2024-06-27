resource "aws_launch_template" "test" {
  image_id               = var.ami_id
  instance_type          = "m5.large"
  name                   = "test"
  update_default_version = true

  user_data = base64encode(templatefile("userdata.tpl", {
    CLUSTER_NAME       = aws_eks_cluster.this.name,
    B64_CLUSTER_CA     = aws_eks_cluster.this.certificate_authority[0].data,
    API_SERVER_URL     = aws_eks_cluster.this.endpoint,
    KUBELET_EXTRA_ARGS = "--kubelet-extra-args \"--node-labels=kube/nodetype=test \""
  }))

  metadata_options {
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 40
      volume_type = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name        = "test",
        environment = "test"
      },
      var.default_tags
    )
  }
}

resource "aws_eks_node_group" "test" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "test"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    min_size     = 1
    desired_size = 1
    max_size     = 1
  }
  labels = {
    "kube/nodetype" = "test"
  }

  capacity_type = "ON_DEMAND" # ON_DEMAND, SPOT

  tags = {
    Name        = "test"
    environment = "test"
  }

  launch_template {
    id      = aws_launch_template.test.id
    version = aws_launch_template.test.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]
}

resource "aws_autoscaling_group_tag" "test" {
  for_each               = var.default_tags
  autoscaling_group_name = aws_eks_node_group.test.resources[0].autoscaling_groups[0].name
  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}
