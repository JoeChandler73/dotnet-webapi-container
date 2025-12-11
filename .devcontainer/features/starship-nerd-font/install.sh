#!/bin/bash
set -e

# Variables automatically injected by the Dev Container engine
USERNAME=${_REMOTE_USER:-"vscode"}
HOME_DIR="/home/${USERNAME}"

# Feature options (injected as environment variables with uppercase names)
NERD_FONT=${NERDFONT:-"Hack"}
STARSHIP_PRESET=${STARSHIPPRESET:-"catppuccin-powerline"}
FONT_VERSION=${FONTVERSION:-"v3.4.0"}

echo "Starting dev container customization for user: ${USERNAME}"
echo "Configuration: Font=${NERD_FONT}, Preset=${STARSHIP_PRESET}"

# --- Step 1: Install dependencies ---
echo "Installing fontconfig and unzip..."
export DEBIAN_FRONTEND=noninteractive
apt-get update && \
apt-get install -y --no-install-recommends \
    fontconfig \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# --- Step 2: Install Nerd Fonts ---
echo "Installing Nerd Font: ${NERD_FONT}..."
FONT_DIR="${HOME_DIR}/.local/share/fonts"
mkdir -p "${FONT_DIR}"

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/${NERD_FONT}.zip"

if curl -fsSL "${FONT_URL}" -o "${FONT_DIR}/${NERD_FONT}.zip"; then
    unzip -q "${FONT_DIR}/${NERD_FONT}.zip" -d "${FONT_DIR}"
    rm "${FONT_DIR}/${NERD_FONT}.zip"
    # Remove Windows-specific files if any
    find "${FONT_DIR}" -name "*Windows Compatible*" -delete
    fc-cache -fv
    echo "Nerd Font '${NERD_FONT}' installed successfully."
else
    echo "Warning: Failed to download Nerd Font '${NERD_FONT}'. Continuing anyway..."
fi

# --- Step 3: Install Starship ---
echo "Installing Starship prompt..."
if curl -fsSL https://starship.rs/install.sh | sh -s -- -y; then
    echo "Starship installed successfully."
else
    echo "Error: Starship installation failed."
    exit 1
fi

# --- Step 4: Configure Starship ---
echo "Configuring Starship with preset: ${STARSHIP_PRESET}..."

# Add Starship initialization to .bashrc if not already present
if ! grep -q "starship init bash" "${HOME_DIR}/.bashrc" 2>/dev/null; then
    cat << 'EOF' >> "${HOME_DIR}/.bashrc"

# --- Starship Prompt Configuration ---
eval "$(starship init bash)"
EOF
    echo "Added Starship to .bashrc"
else
    echo "Starship already configured in .bashrc"
fi

# Set up Starship config
mkdir -p "${HOME_DIR}/.config"
if command -v starship >/dev/null 2>&1; then
    starship preset "${STARSHIP_PRESET}" -o "${HOME_DIR}/.config/starship.toml"
    echo "Starship preset '${STARSHIP_PRESET}' configured."
fi

# --- Step 5: Fix permissions ---
echo "Fixing permissions..."
chown -R "${USERNAME}:${USERNAME}" "${HOME_DIR}/.local" 2>/dev/null || true
chown -R "${USERNAME}:${USERNAME}" "${HOME_DIR}/.config" 2>/dev/null || true

echo "Dev container customization complete!"
echo "Font: ${NERD_FONT} | Preset: ${STARSHIP_PRESET}"