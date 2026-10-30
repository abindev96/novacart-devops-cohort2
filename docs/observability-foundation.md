where logs go:Azure Container Apps application logs and platform logs are collected in Log Analytics

what telemetry the application or platform emits:Azure Monitor collects platform metrics such as CPU, memory, replica count, restarts, and network activity from Azure Container Apps, while diagnostic settings send application console/system logs and PostgreSQL diagnostic logs to Log Analytics for querying, troubleshooting, and monitoring.

what metrics matter for this workload:CPU, memory, replica count, HTTP 5xx errors, request latency, PostgreSQL CPU, storage, IOPS, and active connections are important.

how health is checked:/health and /ready endpoints provide application health checks, while Azure Container Apps health probes verify container availability.

what signals would help during an incident:HTTP 5xx errors, response latency, container restarts, PostgreSQL connection failures, database logs, and resource utilisation

what alert conditions are meaningful:Sustained high CPU or memory, storage above 80%, increased failed connections, HTTP 5xx spikes, unavailable replicas, and repeated application restarts.

what would create alert noise:Very low thresholds, short evaluation windows, alerts on temporary CPU spikes