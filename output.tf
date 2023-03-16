output "cluster_id" {
    value = module.eks.cluster_id
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint
}

output "kubernetes_config" {
  value = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
  description = "Kubernetes provider configuration"
  sensitive   = true
}
