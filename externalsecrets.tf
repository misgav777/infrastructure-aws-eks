# Install External Secrets Operator using Helm
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "external-secrets"
  create_namespace = true
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  depends_on = [
    aws_eks_node_group.SPOT,
    helm_release.nginx_ingress,
    helm_release.argocd
  ]
}

resource "null_resource" "apply_external_secrets_manifests" {
  depends_on = [
    helm_release.external_secrets,
    helm_release.argocd,
    aws_iam_role.external_secrets_role
  ]
  
  triggers = {
    cluster_endpoint = aws_eks_cluster.cluster.endpoint
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${var.eks_name} --region ${var.region}

      
      # Apply all manifests in order
      kubectl apply -f ${path.module}/manifests/secret-store.yaml
      kubectl apply -f ${path.module}/manifests/external-secret.yaml
    EOT
  }
}

resource "kubernetes_service_account" "external_secrets_sa" {
  metadata {
    name      = "external-secrets-sa"
    namespace = "argocd"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_role.arn
    }
  }
  
  depends_on = [aws_iam_role_policy_attachment.external_secrets_attachment]
}
