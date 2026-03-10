# Testing infrastructure deployment commands for MathTrail
# Deployment is managed exclusively by ArgoCD (mathtrail-k6-operator Application).

set shell := ["bash", "-c"]

NAMESPACE := "k6-operator-system"

# Trigger ArgoCD sync
sync:
    argocd app sync mathtrail-k6-operator

# Show ArgoCD application status
status:
    argocd app get mathtrail-k6-operator
    @echo ""
    @echo "📋 TestRun resources:"
    kubectl get testrun -n {{ NAMESPACE }} 2>/dev/null || echo "  No test runs found"
