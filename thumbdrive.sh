#!/usr/bin/env bash
set -euo pipefail

# setup a fresh ubunto 24.04 box with the evening-box stack:
# nginx, 1b ollama + gemma2.2, claude code, github cli

echo "==> Updating apt and installing base packages"
apt update
apt install -y nginx git curl

echo "==> Installing Ollama and pulling llama3.2:1b"
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2:1b
ollama pull gemma2:2b

echo "==> Installing Claude Code"
curl -fsSL https://claude.ai/install.sh | bash
if ! grep -q 'HOME/.local/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

echo "==> Installing GitHub CLI"
if ! command -v gh >/dev/null; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  apt update
  apt install -y gh
fi

rm -rf /tmp/site
git clone https://github.com/amatthewkelly/evening-box-site.git /tmp/site
cp /tmp/site/index.html /var/www/html/index.html

echo "==> Done. To finish:"
echo ""
echo "    Site live at: http://$(curl -4 -s ifconfig.me)"
echo ""
echo "    source ~/.bashrc"
echo "    claude            # auth Claude Code"
echo "    gh auth login     # auth GitHub"

