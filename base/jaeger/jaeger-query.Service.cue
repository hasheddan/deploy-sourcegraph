package kube

service: "jaeger-query": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name: "jaeger-query"
		labels: {
			"sourcegraph-resource-requires": "no-cluster-admin"
			app:                             "jaeger"
			"app.kubernetes.io/name":        "jaeger"
			"app.kubernetes.io/component":   "query"
		}
	}
	spec: {
		ports: [{
			name:       "query-http"
			port:       16686
			protocol:   "TCP"
			targetPort: 16686
		}]
		selector: {
			"app.kubernetes.io/name":      "jaeger"
			"app.kubernetes.io/component": "all-in-one"
		}
		type: "ClusterIP"
	}
}