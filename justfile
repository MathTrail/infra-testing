# Testing infrastructure deployment commands for MathTrail

set shell := ["bash", "-c"]

NAMESPACE := "k6-operator-system"

# Deploy testing infra (k6) to the cluster
deploy:
    #!/bin/bash
    set -e
    
    echo "🚀 Deploying with Skaffold..."
    kubectl create namespace {{ NAMESPACE }} 2>/dev/null || true
    skaffold run
    
    echo ""
    echo "✅ Deployment complete!"

# Remove testing infra from the cluster
delete:
    #!/bin/bash
    set -e
    echo "🗑️  Removing with Skaffold..."
    skaffold delete
    echo ""
    echo "✅ Removal complete!"

# Show deployment status
status:
    #!/bin/bash
    echo "📊 k6 operator status:"
    kubectl get pods -n {{ NAMESPACE }} -l app.kubernetes.io/name=k6-operator 2>/dev/null || echo "  Not deployed"
    echo ""
    echo "📋 TestRun resources:"
    kubectl get testrun -n {{ NAMESPACE }} 2>/dev/null || echo "  No test runs found"
