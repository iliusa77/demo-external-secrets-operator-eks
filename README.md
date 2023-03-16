## AWS Infrastructure and Kubernetes entities deployment with Terraform

These TF templates are prepared for the `Manage secrets with AWS Secrets Manager and Kubernetes External Secrets Operator on EKS cluster` demo


### Terraform init/plan/apply
```
terraform init

terraform plan
var.profile
  AWS credentials profile you want to use
  Enter a value: default

terraform apply -auto-approve
```

### Add new EKS cluster in kubeconfig
```
aws eks list-clusters

{
    "clusters": [
        "demo-externalsecrets-eks"
    ]
}

aws eks update-kubeconfig --region eu-west-1 --name demo-externalsecrets-eks
```

### Check ClusterSecretStore and ExternalSecret
```
kubectl get ClusterSecretStore demo-externalsecrets-secret-store
kubectl describe ClusterSecretStore demo-externalsecrets-secret-store

kubectl get ExternalSecret redis-password
kubectl describe ExternalSecret redis-password
```

### Check 'redis' chart status, version and pods status
```
helm ls | grep redis
kubectl get po | grep redis
```

### Terraform cleanup
```
terraform destroy -auto-approve
```


useful references:
- https://www.kloia.com/blog/kubernetes-secret-management-using-the-external-secrets-operator-eks
- https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest
- https://medium.com/@danieljimgarcia/dont-use-the-terraform-kubernetes-manifest-resource-6c7ff4fe629a
- https://stackoverflow.com/questions/67370473/failed-to-construct-rest-client
- https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
- https://phoenixnap.com/kb/kubernetes-redis
- https://github.com/bitnami/charts/tree/main/bitnami/redis
- https://shipit.dev/posts/setting-up-eks-with-irsa-using-terraform.html
- https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/