#!/bin/bash
set -e

# --- Step 1: Install dependencies ---
echo "Installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    vim \
    nano \
    less \
    ca-certificates \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# --- Step 2: Install kubectl ---
# Use the official install script for the latest stable version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
chmod +x kubectl && \
mv kubectl /usr/local/bin/

# --- Step 3: Install k9s ---
# You can download the binary directly from the GitHub releases page.
# Find the latest release version on the k9s repository.
K9S_VERSION="v0.32.4"
wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz && \
tar -xzf k9s_Linux_amd64.tar.gz -C /usr/local/bin k9s && \
rm k9s_Linux_amd64.tar.gz