#!/bin/bash
# setup.sh — Jalankan sekali di Codespaces untuk install semua tools
# Usage: bash setup.sh

set -e
echo "=== Setup DEZoomcamp26 Environment ==="

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
export PATH="$HOME/.bruin/bin:$HOME/google-cloud-sdk/bin:$LOCAL_BIN:$PATH"

append_to_bashrc() {
  if [ -w "$HOME/.bashrc" ] || [ ! -e "$HOME/.bashrc" ] && [ -w "$HOME" ]; then
    echo "$1" >> "$HOME/.bashrc"
  else
    echo "Skipping ~/.bashrc update because it is not writable in this environment."
  fi
}

# ── 1. Install Bruin CLI ──────────────────────────────────────────────────────
echo ""
echo "[1/4] Installing Bruin CLI..."
curl -LsSf https://getbruin.com/install/cli | sh
append_to_bashrc 'export PATH="$HOME/.local/bin:$PATH"'
bruin --version

# ── 2. Install Terraform ──────────────────────────────────────────────────────
echo ""
echo "[2/4] Installing Terraform 1.7.5..."
TERRAFORM_VERSION="1.7.5"
curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o /tmp/terraform.zip
unzip -o /tmp/terraform.zip -d "$LOCAL_BIN"
rm /tmp/terraform.zip
append_to_bashrc 'export PATH="$HOME/.local/bin:$PATH"'
terraform version

# ── 3. Install Google Cloud CLI ───────────────────────────────────────────────
echo ""
echo "[3/4] Installing gcloud CLI..."
curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts
append_to_bashrc 'export PATH="$HOME/google-cloud-sdk/bin:$PATH"'

# ── 4. Install Python dependencies ────────────────────────────────────────────
echo ""
echo "[4/4] Installing Python dependencies..."
pip install -r requirements.txt --quiet

# ── Finalize local folders ────────────────────────────────────────────────────
mkdir -p .secrets
echo ".secrets/" >> .gitignore 2>/dev/null || true

echo ""
echo "=== Setup complete! ==="
echo ""
echo "Next steps:"
echo "  1. Copy .env.example ke .env dan isi semua nilai"
echo "  2. Simpan GCP service account key ke .secrets/gcp-sa-key.json"
echo "  3. cd infra && terraform init && terraform apply"
echo "  4. bruin run assets/"
