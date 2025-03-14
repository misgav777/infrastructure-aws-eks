resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

   # Increase the timeout to 10 minutes (600 seconds)
  timeout = 1200
  
  # Enable waiting for load balancer to be ready
  wait       = true
  wait_for_jobs = true
  
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }
  
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }
  
  set {
    name  = "controller.ingressClassResource.name"
    value = "nginx"
  }
  
  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }
  
  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  
  depends_on = [
    aws_eks_node_group.SPOT
  ]
}