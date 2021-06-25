terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.33"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.3.2"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn = var.assume_role_arn
  }
}

data "terraform_remote_state" "infra_networking" {
  backend = "s3"
  config = {
    bucket   = var.govuk_aws_state_bucket
    key      = "govuk/infra-networking.tfstate"
    region   = "eu-west-1"
    role_arn = var.assume_role_arn
  }
}


resource "aws_iam_role" "k8s-role-fred" {
  name = "eks-cluster-example"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "k8s-AmazonEKSClusterPolicy-fred" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8s-role-fred.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "k8s-AmazonEKSVPCResourceController-fred" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.k8s-role-fred.name
}

resource "aws_eks_cluster" "fred" {
  name     = "fred"
  role_arn = aws_iam_role.k8s-role-fred.arn

  vpc_config {
    subnet_ids = data.terraform_remote_state.infra_networking.outputs.private_subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.k8s-AmazonEKSClusterPolicy-fred,
    aws_iam_role_policy_attachment.k8s-AmazonEKSVPCResourceController-fred,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.fred.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.fred.certificate_authority[0].data
}
