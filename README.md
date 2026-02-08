# aiautocommitmessage

AI-powered conventional commit message generator for ZSH. Uses Claude Haiku or GPT-4o-mini for fast, accurate commit messages.

## Features

- **Fast**: Sub-second generation with Claude Haiku or GPT-4o-mini
- **Simple**: Just run `aicommit` or `ac` after staging changes
- **Flexible**: Supports both Anthropic and OpenAI APIs
- **Conventional**: Generates proper conventional commit format

## Requirements

- ZSH
- `jq` - Install with `brew install jq`
- API key: `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`

## Installation

### Oh My ZSH

```bash
git clone https://github.com/tawanorg/aiautocommitmessage ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/aiautocommitmessage
```

Add to `~/.zshrc`:
```bash
plugins=(... aiautocommitmessage)
```

### Zinit

```bash
zinit light tawanorg/aiautocommitmessage
```

### Manual

```bash
git clone https://github.com/tawanorg/aiautocommitmessage ~/.aiautocommitmessage
echo 'source ~/.aiautocommitmessage/aiautocommitmessage.zsh' >> ~/.zshrc
```

### One-liner

```bash
curl -fsSL https://raw.githubusercontent.com/tawanorg/aiautocommitmessage/main/install.sh | bash
```

## Configuration

Set your API key in `~/.zshrc`:

```bash
# Option 1: Anthropic (recommended - faster)
export ANTHROPIC_API_KEY="sk-ant-..."

# Option 2: OpenAI
export OPENAI_API_KEY="sk-..."
```

## Usage

Just use git normally - AI generates commit messages automatically:

```bash
git add .
git commit   # AI generates the message!
```

That's it. The plugin wraps `git commit` to auto-generate messages.

## Commands

| Command | Description |
|---------|-------------|
| `git commit` | Auto-generates AI commit message |
| `git commit -m "msg"` | Normal commit (AI skipped) |
| `aicommit-off` | Disable AI temporarily |
| `aicommit-on` | Re-enable AI |
| `ac` | Manual: generate and commit |
| `acf` | Stage all + AI commit |

## How It Works

1. Plugin wraps the `git` command
2. When you run `git commit` (without `-m`), it intercepts
3. Reads staged diff, calls AI API
4. Commits with generated message
5. `git commit -m "..."` bypasses AI (normal behavior)

## Example

```bash
# With hook installed
$ git add src/auth.ts
$ git commit
AI generated: feat(auth): add JWT token refresh mechanism
[main 1a2b3c4] feat(auth): add JWT token refresh mechanism
 1 file changed, 45 insertions(+), 12 deletions(-)
```

## License

MIT
