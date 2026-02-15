# Testing infrastructure deployment commands for MathTrail

set shell := ["bash", "-c"]

NAMESPACE := "mathtrail"
CI_NAMESPACE := "mathtrail-ci"

# Deploy all testing infra (k6 + runner) to the cluster
deploy:
    #!/bin/bash
    set -e
    
    # Load environment
    if [ -f .env ]; then
        set -a
        source .env
        set +a
    else
        echo "❌ Missing .env file. Copy from .env.example and add token:"
        echo "   cp .env.example .env"
        echo "   # Edit .env and set GITHUB_RUNNER_TOKEN"
        exit 1
    fi
    
    if [ -z "$GITHUB_RUNNER_TOKEN" ]; then
        echo "❌ GITHUB_RUNNER_TOKEN not set in .env"
        exit 1
    fi
    
    echo "🚀 Deploying with Skaffold..."
    kubectl create namespace {{ NAMESPACE }} 2>/dev/null || true
    skaffold run
    
    echo "🚀 Deploying GitHub runner..."
    kubectl create namespace {{ CI_NAMESPACE }} 2>/dev/null || true
    helm upgrade --install github-runner ../charts/charts/github-runner \
        --namespace {{ CI_NAMESPACE }} \
        --values values/github-runner-values.yaml \
        --set github.runnerToken="$GITHUB_RUNNER_TOKEN" \
        --wait
    
    echo ""
    echo "✅ Deployment complete!"

# Build and push the CI runner image only
build-runner:
    cd runner && just push

# Remove all testing infra from the cluster
uninstall:
    #!/bin/bash
    set -e
    echo "🗑️  Removing with Skaffold..."
    skaffold delete
    echo ""
    echo "🗑️  Removing GitHub runner..."
    helm uninstall github-runner -n {{ CI_NAMESPACE }} 2>/dev/null || true
    kubectl delete namespace {{ CI_NAMESPACE }} --ignore-not-found 2>/dev/null || true
    echo ""
    echo "✅ Removal complete!"

# Show deployment status
status:
    #!/bin/bash
    echo "📊 k6 operator status:"
    kubectl get pods -n {{ NAMESPACE }} -l app.kubernetes.io/name=k6-operator 2>/dev/null || echo "  Not deployed"
    echo ""
    echo "📊 GitHub runner status:"
    kubectl get pods -n {{ CI_NAMESPACE }} -l app.kubernetes.io/name=github-runner 2>/dev/null || echo "  Not deployed"
    echo ""
    echo "📋 TestRun resources:"
    kubectl get testrun -n {{ NAMESPACE }} 2>/dev/null || echo "  No test runs found"
