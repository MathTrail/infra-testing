# Identity & Context
You are working on mathtrail-infra-testing — the testing infrastructure for MathTrail.
Deploys k6 operator for distributed load testing and provides E2E test scenarios.
Tests run inside the Kubernetes cluster, not from local machine.

Tech Stack: Grafana k6, k6 Operator, Helm, JavaScript (k6 scripts)
Namespace: k6-operator-system (operator), tests run in same namespace as target services

# Repo Layout
- `skaffold.yaml` — deploys k6-operator Helm release
- `values/k6-operator-values.yaml` — resource limits + `namespace.create: false` (namespace managed by Helm via createNamespace)
- `justfile` — `just deploy`, `just delete`, `just status`

# Key Commands
```bash
just deploy     # deploy k6 operator to k6-operator-system
just delete     # remove k6 operator + delete namespace
just status     # show operator pods and TestRun resources
```

# Communication Map
Tests call: All MathTrail service REST APIs
k6 operator: Runs test pods in the cluster
Results: Exported to Grafana (via infra-observability)

# Namespace Note
The k6-operator chart has `namespace.create: true` by default, which conflicts with
Helm's own `--create-namespace`. Override with `namespace.create: false` (already in values)
so Helm creates the namespace with proper ownership labels via `createNamespace: true` in skaffold.yaml.

# Development Standards
- k6 scripts in JavaScript/TypeScript
- Test scenarios must be idempotent (safe to re-run)
- Load tests must have configurable VU (virtual users) and duration
- E2E scenarios must cover critical user flows: register → login → get task → submit → check progress
- All test data must be cleaned up after runs

# Commit Convention
Use Conventional Commits: feat(testing):, fix(testing):, chore(testing):
Example: feat(testing): add load test for profile service API

# Testing Strategy
k6 scripts in scripts/ directory
Verify via Grafana dashboards (test results, service performance)
Priority: E2E scenario coverage for all critical flows
