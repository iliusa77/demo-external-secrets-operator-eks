### SecretStore
resource "kubectl_manifest" "secret_store" {
  yaml_body  = <<-EOF
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: ${var.project}-secret-store
    spec:
      provider:
        aws:
          service: SecretsManager
          region: ${var.region}
          auth:
            jwt:
              serviceAccountRef:
                name: sa-external-secrets-operator
                namespace: default
    EOF
  depends_on = [
    module.eks
  ]
}

### ExternalSecret
resource "kubectl_manifest" "external_secret" {
  yaml_body  = <<-EOF
    apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: "redis-password"
      namespace: default
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: ${var.project}-secret-store
        kind: ClusterSecretStore
      target:
        name: redis-password
        creationPolicy: Owner
      data:
      - secretKey: redis-password
        remoteRef:
          key: "${ var.aws_secretsmanager_secret_name }"
          decodingStrategy: Auto
    EOF
  depends_on = [
    module.eks,
    kubectl_manifest.secret_store
  ]
}