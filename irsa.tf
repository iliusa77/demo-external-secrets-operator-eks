##### External Secret Operator
data "aws_caller_identity" "current" {}

module "external_secrets_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                             = "${ var.project }-external-secrets"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:${ var.project }-*"]

  oidc_providers = {
    ex = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "secret-operator:${ var.project }-operator",
        "${ var.project }-operator",
        "default",
      ]
    }
  }
}