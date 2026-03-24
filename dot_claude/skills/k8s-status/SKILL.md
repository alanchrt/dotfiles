---
name: k8s-status
description: Show Kubernetes cluster status overview
disable-model-invocation: false
allowed-tools:
  - Bash
  - Read
---

# Kubernetes Status

Gather and present a formatted summary of the current Kubernetes cluster.

## Cluster Context

```
!kubectl config current-context 2>/dev/null || echo "No active context"
```

## Gather Data

Run these read-only commands and present a formatted summary:

1. **Namespaces**: `kubectl get namespaces`
2. **Pods** (all namespaces): `kubectl get pods -A --sort-by='.metadata.namespace'`
3. **Services**: `kubectl get services -A`
4. **Unhealthy pods**: `kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded`
5. **Recent events** (warnings only): `kubectl get events -A --field-selector type=Warning --sort-by='.lastTimestamp' | tail -20`

## Presentation

- Group by namespace
- Highlight any pods not in Running/Succeeded state
- Show resource counts per namespace
- Flag any warnings from recent events
- Keep output concise — summarize, don't dump raw output
