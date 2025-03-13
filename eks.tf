resource "aws_iam_role" "eks" {
  name = "${var.project}-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project}-eks-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster with Enhanced Configuration
resource "aws_eks_cluster" "cluster" {
  name     = var.eks_name
  role_arn = aws_iam_role.eks.arn
  version  = var.eks_version

  vpc_config {
    # Enable both private and public endpoint access for flexibility
    endpoint_private_access = true
    endpoint_public_access  = true

    # Include both private and public subnets for comprehensive networking
    subnet_ids = concat(
      aws_subnet.private_subnet[*].id,
      aws_subnet.public_subnet[*].id
    )
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Make sure IAM role and log group are created first
  depends_on = [aws_iam_role_policy_attachment.eks]

  tags = {
    Name = "${var.project}-cluster"
  }
}