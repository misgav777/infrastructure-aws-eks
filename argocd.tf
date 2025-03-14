resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.46.7"
  timeout          = 600

  values = [file("${path.module}/argocd-values.yaml")]

  depends_on = [
    aws_eks_node_group.SPOT,
    helm_release.nginx_ingress
  ]
}