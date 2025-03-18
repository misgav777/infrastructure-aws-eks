┌─────────────────────────────────────────────────────────────┐
│                      AWS Cloud (ap-south-1)                 │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                  VPC (10.0.0.0/16)                  │    │
│  │                                                     │    │
│  │  ┌─────────────┐                   ┌─────────────┐  │    │
│  │  │ AZ-a        │                   │ AZ-b        │  │    │
│  │  │             │                   │             │  │    │
│  │  │ ┌─────────┐ │                   │ ┌─────────┐ │  │    │
│  │  │ │ Public  │ │                   │ │ Public  │ │  │    │
│  │  │ │ Subnet  │ │                   │ │ Subnet  │ │  │    │
│  │  │ └────┬────┘ │                   │ └────┬────┘ │  │    │
│  │  │      │      │                   │      │      │  │    │
│  │  │ ┌────▼────┐ │                   │ ┌────▼────┐ │  │    │
│  │  │ │ Private │ │                   │ │ Private │ │  │    │
│  │  │ │ Subnet  │ │                   │ │ Subnet  │ │  │    │
│  │  │ └────┬────┘ │                   │ └────┬────┘ │  │    │
│  │  └──────┼──────┘                   └──────┼──────┘  │    │
│  │         │                                 │         │    │
│  │  ┌──────▼─────────────────────────────────▼──────┐  │    │
│  │  │                                               │  │    │
│  │  │               EKS Cluster (v1.32)             │  │    │
│  │  │                                               │  │    │
│  │  │  ┌─────────────────────────────────────────┐  │  │    │
│  │  │  │             Node Group                  │  │  │    │
│  │  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  │  │  │    │
│  │  │  │  │  SPOT   │  │  SPOT   │  │  SPOT   │  │  │  │    │
│  │  │  │  │ t3a.large │ t3a.large │ t3a.large │  │  │  │    │
│  │  │  │  └─────────┘  └─────────┘  └─────────┘  │  │  │    │
│  │  │  └─────────────────────────────────────────┘  │  │    │
│  │  │                                               │  │    │
│  │  │  ┌─────────────┐  ┌─────────┐  ┌───────────┐  │  │    │
│  │  │  │    NGINX    │  │ ArgoCD  │  │  Sealed   │  │  │    │
│  │  │  │   Ingress   │  │         │  │  Secrets  │  │  │    │
│  │  │  └──────┬──────┘  └─────────┘  └───────────┘  │  │    │
│  │  │         │                                     │  │    │
│  │  └─────────┼─────────────────────────────────────┘  │    │
│  │            │                                        │    │
│  └────────────┼────────────────────────────────────────┘    │
│               │                                             │
│    ┌──────────▼──────────┐                                  │
│    │     AWS Network     │                                  │
│    │    Load Balancer    │                                  │
│    └──────────┬──────────┘                                  │
│               │                                             │
└───────────────┼─────────────────────────────────────────────┘
                │
                ▼
        External Traffic


VPC Infrastructure:

VPC with CIDR block 10.0.0.0/16
Public and private subnets across two availability zones
Network routing components (implied)
EKS Cluster:

Kubernetes v1.32
SPOT instance node group (t3a.large)
Autoscaling from 1-3 nodes
Kubernetes Add-ons:

NGINX Ingress Controller (load balancer)
ArgoCD for GitOps deployment
Sealed Secrets for sensitive data management
External Access:

AWS Network Load Balancer
Route for external traffic to cluster services