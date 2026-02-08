#!/usr/bin/env bash
# Quick installer for autocommitmessage ZSH plugin

set -e

INSTALL_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/autocommitmessage"
REPO_URL="https://github.com/tawan/autocommitmessage"

echo "Installing autocommitmessage..."

# Check for dependencies
if ! command -v jq &>/dev/null; then
  echo "Warning: jq is required. Install with: brew install jq"
fi

# Clone or update
if [[ -d "$INSTALL_DIR" ]]; then
  echo "Updating existing installation..."
  cd "$INSTALL_DIR"
  git pull
else
  echo "Installing to $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Make bin script executable
chmod +x "$INSTALL_DIR/bin/aicommit"

echo ""
echo "Installation complete!"
echo ""
echo "Add 'autocommitmessage' to your plugins in ~/.zshrc:"
echo "  plugins=(... autocommitmessage)"
echo ""
echo "Then reload your shell:"
echo "  source ~/.zshrc"
echo ""
echo "Set your API key:"
echo "  export ANTHROPIC_API_KEY='your-key'  # or"
echo "  export OPENAI_API_KEY='your-key'"
