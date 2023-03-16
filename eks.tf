module "eks"{
    source = "terraform-aws-modules/eks/aws"
    version = "17.18.0"
    cluster_name = local.cluster_name
    cluster_version = "1.24"
    subnets = module.vpc.private_subnets
    cluster_endpoint_public_access  = true
    enable_irsa                     = true

tags = {
        Name = "${ var.project }-eks"
    }
vpc_id = module.vpc.vpc_id
    workers_group_defaults = {
        root_volume_type = "gp2"
    }
worker_groups = [
        {
            name = "Worker-Group-1"
            instance_type = "t2.small"
            capacity_type = "SPOT"
            asg_desired_capacity = 1
            additional_security_group_ids = [aws_security_group.worker_group_one.id]
        },
        {
            name = "Worker-Group-2"
            instance_type = "t2.small"
            capacity_type = "SPOT"
            asg_desired_capacity = 1
            additional_security_group_ids = [aws_security_group.worker_group_two.id]
        },
    ]
}

data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_id
}

resource "aws_eks_identity_provider_config" "cluster" {
 cluster_name = module.eks.cluster_name
 oidc {
 client_id = “${substr(aws_eks_cluster.demo.identity.0.oidc.0.issuer, -32, -1)}”
 identity_provider_config_name = "sdemonew"
 issuer_url = “https://${aws_iam_openid_connect_provider.demo.url}”
 
 }
}