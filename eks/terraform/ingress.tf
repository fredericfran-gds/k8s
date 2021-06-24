resource "kubernetes_cluster_role" "alb-ingress-controller-role-fred" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name" = "alb-ingress-controller"
    }
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["configmaps", "endpoints", "events", "ingresses", "ingresses/status", "services"]
    verbs      = [ "create", "get", "list", "update", "watch", "patch"]
  }

  rule {
    api_groups = ["", "extensions"]
    resources  = ["nodes","pods","secrets","services","namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_service_account" "alb-ingress-controller-service-account-fred" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name" = "alb-ingress-controller",
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.alb-ingress-controller-k8s-fred.arn}"
    }
    namespace = "kube-system"
  }

}

resource "kubernetes_cluster_role_binding" "alb-ingress-controller-role-binding-fred" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name" = "alb-ingress-controller"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.alb-ingress-controller-role-fred.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.alb-ingress-controller-service-account-fred.metadata.0.name
    namespace = "kube-system"
  }
}

resource "aws_iam_policy" "ALBIngressControllerIAMPolicy-fred" {
  name   = "ALBIngressControllerIAMPolicy"
  policy = jsonencode({
    "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "acm:DescribeCertificate",
       "acm:ListCertificates",
       "acm:GetCertificate"
     ],
     "Resource": "*"
   },
   {
     "Effect": "Allow",
     "Action": [
       "ec2:AuthorizeSecurityGroupIngress",
       "ec2:CreateSecurityGroup",
       "ec2:CreateTags",
       "ec2:DeleteTags",
       "ec2:DeleteSecurityGroup",
       "ec2:DescribeAccountAttributes",
       "ec2:DescribeAddresses",
       "ec2:DescribeInstances",
       "ec2:DescribeInstanceStatus",
       "ec2:DescribeInternetGateways",
       "ec2:DescribeNetworkInterfaces",
       "ec2:DescribeSecurityGroups",
       "ec2:DescribeSubnets",
       "ec2:DescribeTags",
       "ec2:DescribeVpcs",
       "ec2:ModifyInstanceAttribute",
       "ec2:ModifyNetworkInterfaceAttribute",
       "ec2:RevokeSecurityGroupIngress"
     ],
     "Resource": "*"
   },
   {
     "Effect": "Allow",
     "Action": [
       "elasticloadbalancing:AddListenerCertificates",
       "elasticloadbalancing:AddTags",
       "elasticloadbalancing:CreateListener",
       "elasticloadbalancing:CreateLoadBalancer",
       "elasticloadbalancing:CreateRule",
       "elasticloadbalancing:CreateTargetGroup",
       "elasticloadbalancing:DeleteListener",
       "elasticloadbalancing:DeleteLoadBalancer",
       "elasticloadbalancing:DeleteRule",
       "elasticloadbalancing:DeleteTargetGroup",
       "elasticloadbalancing:DeregisterTargets",
       "elasticloadbalancing:DescribeListenerCertificates",
       "elasticloadbalancing:DescribeListeners",
       "elasticloadbalancing:DescribeLoadBalancers",
       "elasticloadbalancing:DescribeLoadBalancerAttributes",
       "elasticloadbalancing:DescribeRules",
       "elasticloadbalancing:DescribeSSLPolicies",
       "elasticloadbalancing:DescribeTags",
       "elasticloadbalancing:DescribeTargetGroups",
       "elasticloadbalancing:DescribeTargetGroupAttributes",
       "elasticloadbalancing:DescribeTargetHealth",
       "elasticloadbalancing:ModifyListener",
       "elasticloadbalancing:ModifyLoadBalancerAttributes",
       "elasticloadbalancing:ModifyRule",
       "elasticloadbalancing:ModifyTargetGroup",
       "elasticloadbalancing:ModifyTargetGroupAttributes",
       "elasticloadbalancing:RegisterTargets",
       "elasticloadbalancing:RemoveListenerCertificates",
       "elasticloadbalancing:RemoveTags",
       "elasticloadbalancing:SetIpAddressType",
       "elasticloadbalancing:SetSecurityGroups",
       "elasticloadbalancing:SetSubnets",
       "elasticloadbalancing:SetWebACL"
     ],
     "Resource": "*"
   },
   {
     "Effect": "Allow",
     "Action": [
       "iam:CreateServiceLinkedRole",
       "iam:GetServerCertificate",
       "iam:ListServerCertificates"
     ],
     "Resource": "*"
   },
   {
     "Effect": "Allow",
     "Action": [
       "cognito-idp:DescribeUserPoolClient"
     ],
     "Resource": "*"
   },
   {
     "Effect": "Allow",
     "Action": [
       "waf-regional:GetWebACLForResource",
       "waf-regional:GetWebACL",
       "waf-regional:AssociateWebACL",
       "waf-regional:DisassociateWebACL"
     ],
     "Resource": "*"
   },
   {
     "Effect": "Allow",
     "Action": [
       "tag:GetResources",
       "tag:TagResources"
     ],
     "Resource": "*"
   },
   {
     "Effect": "Allow",
     "Action": [
       "waf:GetWebACL"
     ],
     "Resource": "*"
   },
 ]})
}

resource "aws_iam_role" "alb-ingress-controller-k8s-fred" {
  name = "alb-ingress-controller"

  assume_role_policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": aws_iam_openid_connect_provider.k8s-openid-fred.arn
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${replace(aws_iam_openid_connect_provider.k8s-openid-fred.url, "https://", "")}:sub": "system:serviceaccount:kube-system:alb-ingress-controller"
        }
      }
    }
  ]
}
)

  managed_policy_arns = [aws_iam_policy.ALBIngressControllerIAMPolicy-fred.arn]
}

resource "kubernetes_deployment" "k8s-alb-ingress-controller-fred" {
  metadata {
    name = "alb-ingress-controller"
    labels = {
      "app.kubernetes.io/name" = "alb-ingress-controller"
    }
    namespace = "kube-system"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "alb-ingress-controller"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "alb-ingress-controller"
        }
      }

      spec {
        container {
          image = "docker.io/amazon/aws-alb-ingress-controller:v1.1.4"
          name  = "alb-ingress-controller"
          args  = ["--cluster-name=fred"]
          }
        service_account_name = "alb-ingress-controller"
        }

      }
    }
}

resource "kubernetes_ingress" "global-ingress-fred" {
  metadata {
    name = "global-ingress"
    annotations = {
       "kubernetes.io/ingress.class" : "alb"
       "alb.ingress.kubernetes.io/scheme" : "internet-facing"
    }
  }

  spec {
    backend {
      service_name = "content-store"
      service_port = 80
    }

    rule {
      http {
        path {
          backend {
            service_name = "content-store"
            service_port = 80
          }

          path = "/content-store/*"
        }
      }
    }

  }

  wait_for_load_balancer = true
}

# Display load balancer hostname (typically present in AWS)
output "load_balancer_hostname" {
  value = kubernetes_ingress.global-ingress-fred.status.0.load_balancer.0
}

# Display load balancer IP (typically present in GCP, or using Nginx ingress controller)
#output "load_balancer_ip" {
#  value = data.kubernetes_ingress.global_ingress.status.0.load_balancer.0.ingress.0.ip
#}
