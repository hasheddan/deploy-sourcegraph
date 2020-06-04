package kube

deployment: pgsql: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		annotations: description:                "Postgres database for various data."
		labels: "sourcegraph-resource-requires": "no-cluster-admin"
		name: "pgsql"
	}
	spec: {
		minReadySeconds:      10
		revisionHistoryLimit: 10
		selector: matchLabels: app: "pgsql"
		strategy: type: "Recreate"
		template: {
			metadata: labels: {
				deploy: "sourcegraph"
				app:    "pgsql"
				group:  "backend"
			}
			spec: {
				initContainers: [{
					name:  "correct-data-dir-permissions"
					image: "sourcegraph/alpine:3.10@sha256:4d05cd5669726fc38823e92320659a6d1ef7879e62268adec5df658a0bacf65c"
					command: ["sh", "-c", "if [ -d /data/pgdata-11 ]; then chmod 750 /data/pgdata-11; fi"]
					volumeMounts: [{
						mountPath: "/data"
						name:      "disk"
					}]
					securityContext: runAsUser: 0
				}]
				containers: [{
					env: []
					image:                    "index.docker.io/sourcegraph/postgres-11.4:3.16.0@sha256:63090799b34b3115a387d96fe2227a37999d432b774a1d9b7966b8c5d81b56ad"
					terminationMessagePolicy: "FallbackToLogsOnError"
					readinessProbe: exec: command: [
						"/ready.sh",
					]
					livenessProbe: {
						initialDelaySeconds: 15
						exec: command: [
							"/liveness.sh",
						]
					}
					name: "pgsql"
					ports: [{
						containerPort: 5432
						name:          "pgsql"
					}]
					resources: {
						limits: {
							cpu:    *"4" | string | int
							memory: *"2Gi" | string | int
						}
						requests: {
							cpu:    *"4" | string | int
							memory: *"2Gi" | string | int
						}
					}
					volumeMounts: [{
						mountPath: "/data"
						name:      "disk"
					}, {
						mountPath: "/conf"
						name:      "pgsql-conf"
					}]
				}, {
					env: [{
						name:  "DATA_SOURCE_NAME"
						value: "postgres://sg:@localhost:5432/?sslmode=disable"
					}]
					image:                    "wrouesnel/postgres_exporter:v0.7.0@sha256:785c919627c06f540d515aac88b7966f352403f73e931e70dc2cbf783146a98b"
					terminationMessagePolicy: "FallbackToLogsOnError"
					name:                     "pgsql-exporter"
					resources: {
						limits: {
							cpu:    *"10m" | string | int
							memory: *"50Mi" | string | int
						}
						requests: {
							cpu:    *"10m" | string | int
							memory: *"50Mi" | string | int
						}
					}
				}]
				securityContext: runAsUser: 0
				volumes: [{
					name: "disk"
					persistentVolumeClaim: claimName: "pgsql"
				}, {
					name: "pgsql-conf"
					configMap: {
						defaultMode: 0o777
						name:        "pgsql-conf"
					}
				}]
			}
		}
	}
}