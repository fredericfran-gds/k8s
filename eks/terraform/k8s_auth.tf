data "aws_eks_cluster" "fred" {
  name = "fred"
}

data "aws_eks_cluster_auth" "fred-auth" {
  name = "fred"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.fred.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.fred.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.fred.name]
    command     = "aws"
  }
}

data "tls_certificate" "k8s-tls-fred" {
  url = aws_eks_cluster.fred.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "k8s-openid-fred" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.k8s-tls-fred.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.fred.identity[0].oidc[0].issuer
}
