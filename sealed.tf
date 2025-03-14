resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  namespace  = "kube-system"
  version    = "2.13.0"

  depends_on = [
    aws_eks_node_group.SPOT,
    helm_release.nginx_ingress,
    helm_release.argocd
  ]
}
# Read the sealed secret file
data "local_file" "repo_sealed_secret" {
  filename = "${path.module}/sealed-creds.yaml"
}

# Parse the YAML content
locals {
  sealed_secret = yamldecode(data.local_file.repo_sealed_secret.content)
}

# Apply the sealed secret
resource "kubernetes_manifest" "argocd_repo_credentials" {
  manifest = local.sealed_secret

  depends_on = [
    helm_release.argocd,
    helm_release.sealed_secrets
  ]
}