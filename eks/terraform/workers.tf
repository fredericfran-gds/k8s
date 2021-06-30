resource "aws_iam_role" "k8s-fred-worker-role" {
  name = "k8s-fred-worker-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "k8s-AmazonEKSWorkerNodePolicy-fred" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8s-fred-worker-role.name
}

resource "aws_iam_role_policy_attachment" "k8s-AmazonEKS_CNI_Policy-fred" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8s-fred-worker-role.name
}

resource "aws_iam_role_policy_attachment" "k8s-AmazonEC2ContainerRegistryReadOnly-fred" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8s-fred-worker-role.name
}


resource "aws_eks_node_group" "k8s-fred-node-group" {
  cluster_name    = aws_eks_cluster.fred.name
  node_group_name = "fred"
  node_role_arn   = aws_iam_role.k8s-fred-worker-role.arn
  subnet_ids      = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids

  instance_types  = ["m5.4xlarge"]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.k8s-AmazonEKSWorkerNodePolicy-fred,
    aws_iam_role_policy_attachment.k8s-AmazonEKS_CNI_Policy-fred,
    aws_iam_role_policy_attachment.k8s-AmazonEC2ContainerRegistryReadOnly-fred,
  ]
}
