output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.cluster.name
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.cluster.name} --region ${var.region}"
}

output "argocd_url" {
  description = "URL to access ArgoCD"
  value       = "https://${data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress.0.hostname}/argocd"
}

output "argocd_admin_password" {
  description = "Initial admin password for ArgoCD"
  value       = data.kubernetes_secret.argocd_admin_password.data.password
  sensitive   = true  
} 