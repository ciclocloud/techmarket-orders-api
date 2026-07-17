terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Obtener ID de cuenta dinámico para evadir consultas iam:GetRole
data "aws_caller_identity" "current" {}

locals {
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

# 2. Configuración de red (VPC básica con subredes públicas)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "techmarket-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
  
  enable_nat_gateway = false
  enable_vpn_gateway = false

  # Parámetro crítico añadido para permitir despliegue de EKS en subredes públicas
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}

# 3. Creación del Clúster EKS (Recurso Nativo)
resource "aws_eks_cluster" "techmarket" {
  name     = "techmarket-cluster"
  role_arn = local.lab_role_arn
  # Se omite 'version' para delegar la asignación estable predeterminada a AWS

  vpc_config {
    subnet_ids = module.vpc.public_subnets
    endpoint_public_access = true
  }
}

# 4. Creación del Grupo de Nodos (Recurso Nativo)
resource "aws_eks_node_group" "techmarket_nodes" {
  cluster_name    = aws_eks_cluster.techmarket.name
  node_group_name = "techmarket-nodes"
  node_role_arn   = local.lab_role_arn
  subnet_ids      = module.vpc.public_subnets

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 2
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_eks_cluster.techmarket
  ]
}

output "cluster_name" {
  value = aws_eks_cluster.techmarket.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.techmarket.endpoint
}