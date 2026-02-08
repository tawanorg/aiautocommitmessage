# autocommitmessage - AI-powered conventional commit message generator
# https://github.com/tawanorg/aiautocommitmessage

# Store plugin path for aicommit-on
AUTOCOMMITMESSAGE_PLUGIN="${0:A}"

# Wrap git to intercept 'git commit' without -m
git() {
  # Check if this is a commit without a message
  if [[ "$1" == "commit" && "$*" != *"-m"* && "$*" != *"--message"* && "$*" != *"--amend"* ]]; then
    # Check for staged changes
    if command git diff --cached --quiet 2>/dev/null; then
      # No staged changes, let git handle the error
      command git "$@"
      return
    fi

    # Generate AI message
    local message
    message=$(_aicommit_generate)

    if [[ -n "$message" ]]; then
      echo "AI: $message"
      shift  # remove 'commit'
      command git commit -m "$message" "$@"
    else
      # Fallback to normal git commit
      command git "$@"
    fi
  else
    # Pass through to real git
    command git "$@"
  fi
}

# Generate commit message from staged diff
_aicommit_generate() {
  # Check for jq
  if ! command -v jq &>/dev/null; then
    return 1
  fi

  local diff
  diff=$(command git diff --cached --no-color)

  # Truncate if too long
  if [[ ${#diff} -gt 4000 ]]; then
    diff="${diff:0:4000}

[truncated...]"
  fi

  local message=""

  if [[ -n "$ANTHROPIC_API_KEY" ]]; then
    message=$(_aicommit_anthropic "$diff")
  elif [[ -n "$OPENAI_API_KEY" ]]; then
    message=$(_aicommit_openai "$diff")
  fi

  # Clean up message
  if [[ -n "$message" ]]; then
    echo "$message" | sed 's/^["`'"'"']*//;s/["`'"'"']*$//' | xargs
  fi
}

# Anthropic API call (Claude Haiku)
_aicommit_anthropic() {
  local diff="$1"
  local prompt="Generate a conventional commit message for this diff.
Format: <type>(<scope>): <description>
Types: feat, fix, docs, style, refactor, test, chore
Keep under 72 chars. Output ONLY the commit message.

$diff"

  local response
  response=$(curl -s "https://api.anthropic.com/v1/messages" \
    -H "Content-Type: application/json" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -d "$(jq -n \
      --arg prompt "$prompt" \
      '{
        model: "claude-3-5-haiku-latest",
        max_tokens: 100,
        messages: [{role: "user", content: $prompt}]
      }')")

  echo "$response" | jq -r '.content[0].text // empty' 2>/dev/null
}

# OpenAI API call (GPT-4o-mini)
_aicommit_openai() {
  local diff="$1"
  local prompt="Generate a conventional commit message for this diff.
Format: <type>(<scope>): <description>
Types: feat, fix, docs, style, refactor, test, chore
Keep under 72 chars. Output ONLY the commit message.

$diff"

  local response
  response=$(curl -s "https://api.openai.com/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$(jq -n \
      --arg prompt "$prompt" \
      '{
        model: "gpt-4o-mini",
        max_tokens: 100,
        messages: [{role: "user", content: $prompt}]
      }')")

  echo "$response" | jq -r '.choices[0].message.content // empty' 2>/dev/null
}

# Main function
aicommit() {
  # Check for jq dependency
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required. Install with: brew install jq" >&2
    return 1
  fi

  # Check for staged changes
  if command git diff --cached --quiet 2>/dev/null; then
    echo "No staged changes. Stage changes with 'git add' first." >&2
    return 1
  fi

  # Get staged diff
  local diff
  diff=$(command git diff --cached --no-color)

  # Truncate diff if too long (keep first 4000 chars for speed)
  if [[ ${#diff} -gt 4000 ]]; then
    diff="${diff:0:4000}

[diff truncated...]"
  fi

  local message=""

  # Try Anthropic first, then OpenAI
  if [[ -n "$ANTHROPIC_API_KEY" ]]; then
    echo "Generating commit message with Claude..." >&2
    message=$(_aicommit_anthropic "$diff")
  elif [[ -n "$OPENAI_API_KEY" ]]; then
    echo "Generating commit message with GPT-4o-mini..." >&2
    message=$(_aicommit_openai "$diff")
  else
    echo "Error: Set ANTHROPIC_API_KEY or OPENAI_API_KEY" >&2
    return 1
  fi

  # Validate message
  if [[ -z "$message" ]]; then
    echo "Error: Failed to generate commit message" >&2
    return 1
  fi

  # Clean up message (remove quotes, trim whitespace)
  message=$(echo "$message" | sed 's/^["`'"'"']*//;s/["`'"'"']*$//' | xargs)

  # Show and confirm
  echo "Generated: $message" >&2
  echo -n "Commit with this message? [Y/n] " >&2
  read -r confirm

  if [[ "$confirm" =~ ^[Nn] ]]; then
    echo "Aborted." >&2
    return 1
  fi

  # Commit
  command git commit -m "$message"
}

# Disable AI commit wrapper temporarily
aicommit-off() {
  unfunction git 2>/dev/null
  echo "AI commit disabled. Use 'aicommit-on' to re-enable."
}

# Re-enable AI commit wrapper
aicommit-on() {
  source "$AUTOCOMMITMESSAGE_PLUGIN"
  echo "AI commit enabled."
}

# Aliases
alias ac='aicommit'
alias acf='git add -A && aicommit'
