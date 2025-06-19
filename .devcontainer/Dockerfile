# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/dart:stable

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter \
    && chmod -R a+rwx /usr/local/flutter \
    && /usr/local/flutter/bin/flutter doctor --android-licenses || true

ENV PATH="/usr/local/flutter/bin:/root/.pub-cache/bin:${PATH}"

# Install Node.js & npm
RUN apt-get update && apt-get install -y nodejs npm python3 python3-venv git

# Install global npm tools
RUN npm install -g firebase-tools openai

# Install FlutterFire CLI
RUN dart pub global activate flutterfire_cli

# Install GitHub CLI
RUN apt-get install -y curl apt-transport-https gnupg \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y gh

# Pre-create Python venv for agent
RUN python3 -m venv /workspace/.agent_env \
 && /workspace/.agent_env/bin/pip install --upgrade pip openai tiktoken

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
