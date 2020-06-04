package kube

deployment: "redis-store": {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description:                "Redis for storing semi-persistent data like user sessions."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "redis-store"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "redis-store"
		strategy: type: "Recreate"
		template: {
			metadata: labels: {
				deploy: "sourcegraph"
				app:    "redis-store"
			}
			spec: {
				containers: [{
					env: []
					image:                    "index.docker.io/sourcegraph/redis-store:3.16.0@sha256:e8467a8279832207559bdfbc4a89b68916ecd5b44ab5cf7620c995461c005168"
					terminationMessagePolicy: "FallbackToLogsOnError"
					livenessProbe: {
						initialDelaySeconds: 30
						tcpSocket: port: "redis"
					}
					name: "redis-store"
					ports: [{
						containerPort: 6379
						name:          "redis"
					}]
					readinessProbe: {
						initialDelaySeconds: 5
						tcpSocket: port: "redis"
					}
					resources: {
						limits: {
							cpu:    *"1" | string | int
							memory: *"6Gi" | string | int
						}
						requests: {
							cpu:    *"1" | string | int
							memory: *"6Gi" | string | int
						}
					}
					volumeMounts: [{
						mountPath: "/redis-data"
						name:      "redis-data"
					}]
				}, {
					image:                    "index.docker.io/sourcegraph/redis_exporter:18-02-07_bb60087_v0.15.0@sha256:282d59b2692cca68da128a4e28d368ced3d17945cd1d273d3ee7ba719d77b753"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "redis-exporter"
					ports: [{
						containerPort: 9121
						name:          "redisexp"
					}]
					resources: {
						limits: {
							cpu:    *"10m" | string | int
							memory: *"100Mi" | string | int
						}
						requests: {
							cpu:    *"10m" | string | int
							memory: *"100Mi" | string | int
						}
					}
				}]
				securityContext: runAsUser: 0
				volumes: [{
					name: "redis-data"
					persistentVolumeClaim: claimName: "redis-store"
				}]
			}
		}
	}
}