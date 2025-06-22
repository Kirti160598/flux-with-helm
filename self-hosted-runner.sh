#!/bin/bash

set -e

# ✅ Customize these
REPO_URL="https://github.com/Kirti160598/flux-with-helm"
RUNNER_TOKEN="ARGNKDPXDVOPC3FESQFDINDIK7Z6C"
RUNNER_VERSION="2.325.0"
RUNNER_NAME="eks-ec2-runner"
LABELS="self-hosted,eks"

# Install dependencies
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y curl tar git

# Create runner directory
echo "📁 Creating actions-runner directory..."
mkdir -p actions-runner && cd actions-runner

# Download runner
echo "⬇️ Downloading GitHub Actions runner v$RUNNER_VERSION..."
curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Extract
echo "📦 Extracting runner..."
tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Configure runner
echo "⚙️ Configuring runner..."
./config.sh --url "${REPO_URL}" --token "${RUNNER_TOKEN}" --name "${RUNNER_NAME}" --labels "${LABELS}" --unattended

# Setup as system service
echo "🧩 Setting up system service..."
sudo ./svc.sh install
sudo ./svc.sh start

echo "✅ Self-hosted runner installed and started!"
