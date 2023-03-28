#SecretStore
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

#ExternalSecret
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

resource "kubectl_manifest" "redis_cm" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: redis-config
    data:
      redis-config: |
        maxmemory 2mb
        maxmemory-policy allkeys-lru 
    EOF
  depends_on = [
    module.eks,
    kubectl_manifest.external_secret
  ]
}

resource "kubectl_manifest" "redis_pod" {
  yaml_body  = <<-EOF
    apiVersion: v1
    kind: Pod
    metadata:
      name: redis
    spec:
      containers:
      - name: redis
        image: redis:5.0.4
        command:
          - redis-server
          - "/redis-master/redis.conf"
        args:
          - --requirepass
          - $(REDIS_PASSWORD)
        env:
        - name: MASTER
          value: "true"
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: redis-password
              key: redis-password
              optional: false
        ports:
        - containerPort: 6379
        resources:
          limits:
            cpu: "0.1"
        volumeMounts:
        - mountPath: /redis-master-data
          name: data
        - mountPath: /redis-master
          name: config
      volumes:
        - name: data
          emptyDir: {}
        - name: config
          configMap:
            name: redis-config
            items:
            - key: redis-config
              path: redis.conf
    EOF
  depends_on = [
    module.eks,
    kubectl_manifest.external_secret,
    kubectl_manifest.redis_cm
  ]
}

# #Redis chart
# resource "helm_release" "redis" {
#   name       = "redis"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "redis"
#   version    = "17.8.4"
#   namespace  = "default"

#   set {
#     name  = "volumePermissions.enabled"
#     value = true
#   }

#   set {
#     name  = "persistence.storageClass"
#     value = "gp2"
#   }

#   set {
#     name  = "redis.replicas.persistence.storageClass"
#     value = "gp2"
#   }

#   set {
#     name  = "auth.existingSecret"
#     value = "redis-password"
#   }

#   set {
#     name  = "auth.existingSecretPasswordKey"
#     value = "redis-password"
#   }

#   depends_on = [
#     module.eks,
#     kubectl_manifest.external_secret
#   ]
# }