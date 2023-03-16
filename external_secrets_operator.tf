### AWS Secrets Manager

resource "random_password" "redis_password" {
  length  = 10
  special = false
}
resource "aws_secretsmanager_secret" "redis_password" {
  depends_on = [
    random_password.redis_password
  ]
  name = "${ var.aws_secretsmanager_secret_name }"
}
resource "aws_secretsmanager_secret_version" "redis_password" {
  secret_id     = aws_secretsmanager_secret.redis_password.id
  secret_string = random_password.redis_password.result
}
data "aws_secretsmanager_secret_version" "redis_password" {
  depends_on = [
    aws_secretsmanager_secret_version.redis_password
  ]
  secret_id = aws_secretsmanager_secret.redis_password.id
}

# ###### External Secrets Operator 

resource "helm_release" "external_secrets_operator" {
  name       = "external-secrets-operator"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.5.9"
  namespace  = "default"

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.external_secrets_irsa_role.iam_role_arn
    type  = "string"
  }

  set {
    name  = "serviceAccount.name"
    value = "sa-external-secrets-operator"
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }
}

