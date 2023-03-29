### Redis server is presented as an application which use the secret obtained from AWS Secrets Manager

### Redis config
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

### Redis pod
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