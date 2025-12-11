#!/bin/bash
set -e

# Feature options (injected as environment variables)
KUBECTL_VERSION=${KUBECTLVERSION:-"latest"}
K9S_VERSION=${K9SVERSION:-"latest"}
INSTALL_KUBECTX=${INSTALLKUBECTX:-"true"}

echo "Starting kubectl and k9s installation..."
echo "Configuration: kubectl=${KUBECTL_VERSION}, k9s=${K9S_VERSION}, kubectx=${INSTALL_KUBECTX}"

# --- Step 1: Install dependencies ---
echo "Installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update && \
apt-get install -y --no-install-recommends \
    curl \
    wget \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Determine architecture
ARCH=$(uname -m)
case ${ARCH} in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l) ARCH="arm" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac
echo "Detected architecture: ${ARCH}"

# --- Step 2: Install kubectl ---
echo "Installing kubectl (${KUBECTL_VERSION})..."

if [ "${KUBECTL_VERSION}" = "latest" ]; then
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    echo "Latest stable kubectl version: ${KUBECTL_VERSION}"
fi

KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"

if curl -fsSL "${KUBECTL_URL}" -o /tmp/kubectl; then
    # Verify the binary (optional but recommended)
    chmod +x /tmp/kubectl
    mv /tmp/kubectl /usr/local/bin/kubectl
    
    # Verify installation
    if kubectl version --client &>/dev/null; then
        echo "kubectl installed successfully: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    else
        echo "Warning: kubectl binary installed but verification failed"
    fi
else
    echo "Error: Failed to download kubectl"
    exit 1
fi

# --- Step 3: Install k9s ---
echo "Installing k9s (${K9S_VERSION})..."

if [ "${K9S_VERSION}" = "latest" ]; then
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "Latest k9s version: ${K9S_VERSION}"
fi

K9S_URL="https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${ARCH}.tar.gz"

if curl -fsSL "${K9S_URL}" -o /tmp/k9s.tar.gz; then
    tar -xzf /tmp/k9s.tar.gz -C /tmp
    chmod +x /tmp/k9s
    mv /tmp/k9s /usr/local/bin/k9s
    rm /tmp/k9s.tar.gz
    
    # Verify installation
    if k9s version &>/dev/null; then
        echo "k9s installed successfully: $(k9s version --short 2>/dev/null || k9s version | head -n1)"
    else
        echo "Warning: k9s binary installed but verification failed"
    fi
else
    echo "Error: Failed to download k9s"
    exit 1
fi

# --- Step 4: Install kubectx and kubens (optional utilities) ---
if [ "${INSTALL_KUBECTX}" = "true" ]; then
    echo "Installing kubectx and kubens..."
    
    KUBECTX_VERSION=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    # Install kubectx
    if curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx" -o /usr/local/bin/kubectx; then
        chmod +x /usr/local/bin/kubectx
        echo "kubectx installed successfully"
    else
        echo "Warning: Failed to install kubectx"
    fi
    
    # Install kubens
    if curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens" -o /usr/local/bin/kubens; then
        chmod +x /usr/local/bin/kubens
        echo "kubens installed successfully"
    else
        echo "Warning: Failed to install kubens"
    fi
fi

# --- Step 5: Setup bash completion (optional but helpful) ---
echo "Setting up kubectl bash completion..."
kubectl completion bash > /etc/bash_completion.d/kubectl 2>/dev/null || true

echo "kubectl and k9s installation complete!"
echo "Installed versions:"
kubectl version --client --short 2>/dev/null || kubectl version --client | head -n1
k9s version --short 2>/dev/null || k9s version | head -n1