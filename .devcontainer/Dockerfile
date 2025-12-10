# 1. Use the base .NET development container image
FROM mcr.microsoft.com/devcontainers/dotnet:dev-10.0-noble

# 2. Install font configuration
RUN apt-get update && \
    apt-get install -y \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# 3. Set USERNAME variable as the vscode user
ARG USERNAME=vscode

# 4. Install Nerd Fonts and Starship prompt for the user
RUN mkdir -p /home/${USERNAME}/.local/share/fonts && \
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip -o /home/${USERNAME}/.local/share/fonts/Hack.zip && \
    unzip /home/${USERNAME}/.local/share/fonts/Hack.zip -d /home/${USERNAME}/.local/share/fonts && rm /home/${USERNAME}/.local/share/fonts/Hack.zip && \
    fc-cache && \
    curl -L https://starship.rs/install.sh -o /tmp/install.sh && \
    chmod +x /tmp/install.sh && /tmp/install.sh -y && \
    echo "eval ""$(starship init bash)""" >> /home/${USERNAME}/.bashrc && \
    mkdir -p /home/${USERNAME}/.config && touch /home/${USERNAME}/.config/starship.toml && \
    starship preset catppuccin-powerline -o /home/${USERNAME}/.config/starship.toml

# 5. Fix issues with permissions of directories used by NuGet
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.local