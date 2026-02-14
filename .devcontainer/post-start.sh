#!/bin/bash
set -e

mkdir -p /home/vscode/.kube
chmod 700 /home/vscode/.kube 2>/dev/null || true

echo "Checking cluster connection..."
if kubectl cluster-info 2>/dev/null; then
    echo "✅ Connected to K3d cluster"
else
    echo "⚠️  Cluster not accessible. Run \"just create\" on host first (mathtrail-infra-local-k3s)"
fi

echo "Adding MathTrail Helm chart repository..."
helm repo add mathtrail https://MathTrail.github.io/mathtrail-charts/charts
helm repo update mathtrail
echo "✅ Helm repo ready"
``