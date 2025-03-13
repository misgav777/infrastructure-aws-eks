resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.7.1"

  values = [
    file("${path.module}/nginx_ingress_values.yaml")
  ]

  depends_on = [
    aws_eks_node_group.general
  ]
}