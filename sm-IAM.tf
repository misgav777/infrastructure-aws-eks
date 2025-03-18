# Create IAM policy for Secrets Manager access
resource "aws_iam_policy" "external_secrets" {
  name        = "external-secrets-policy"
  description = "Policy for External Secrets Operator to access Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = ["arn:aws:secretsmanager:*:*:secret:argocd/*"]
      },
      {
        Effect = "Allow"
        Action = "secretsmanager:ListSecrets"
        Resource = "*"
      }
    ]
  })
  depends_on = [aws_eks_node_group.SPOT]
}

# Create IAM role for the service account
resource "aws_iam_role" "external_secrets_role" {
  name = "external-secrets-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::713881821143:oidc-provider/${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:argocd:external-secrets-sa"
            "${replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud": "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  depends_on = [aws_eks_node_group.SPOT]
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "external_secrets_attachment" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets.arn

  depends_on = [aws_iam_role.external_secrets_role, aws_iam_policy.external_secrets]
}

# Data sources for account and cluster info
data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = var.eks_name
  depends_on = [aws_eks_cluster.cluster]
}
