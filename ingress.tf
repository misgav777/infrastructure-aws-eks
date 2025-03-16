resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  # Increase the timeout to 10 minutes (600 seconds)
  timeout = 1200

  # Enable waiting for load balancer to be ready
  wait          = true
  wait_for_jobs = true
  values        = [file("${path.module}/ingress-values.yaml")]

  depends_on = [
    aws_eks_node_group.SPOT
  ]
}