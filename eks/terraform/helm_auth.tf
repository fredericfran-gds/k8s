provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.fred.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.fred.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.fred.name]
      command     = "aws"
    }
  }
}
