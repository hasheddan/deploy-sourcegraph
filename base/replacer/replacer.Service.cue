package kube

service: replacer: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "replacer"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "replacer"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       3185
			targetPort: "http"
		}, {
			name:       "debug"
			port:       6060
			targetPort: "debug"
		}]
		selector: app: "replacer"
		type: "ClusterIP"
	}
}