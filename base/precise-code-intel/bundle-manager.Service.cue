package kube

service: "precise-code-intel-bundle-manager": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		annotations: {
			"prometheus.io/port":            "6060"
			"sourcegraph.prometheus/scrape": "true"
		}
		labels: {
			app:                             "precise-code-intel-bundle-manager"
			"sourcegraph-resource-requires": "no-cluster-admin"
		}
		name: "precise-code-intel-bundle-manager"
	}
	spec: {
		ports: [{
			name:       "http"
			port:       3187
			targetPort: "http"
		}, {
			name:       "debug"
			port:       6060
			targetPort: "debug"
		}]
		selector: app: "precise-code-intel-bundle-manager"
		type: "ClusterIP"
	}
}