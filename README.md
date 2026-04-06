# cc — Claude Code Devcontainer CLI

Run [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with `--dangerously-skip-permissions` **safely** inside isolated Docker containers with iptables firewall.

Based on [Anthropic's official devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer), extracted into a reusable CLI that works with any repo.

## Why

Claude Code's `--dangerously-skip-permissions` flag removes all confirmation prompts, letting Claude work autonomously. But running it on your host is risky — it can execute arbitrary commands with your full user permissions.

This tool wraps Claude in a Docker container with:

- **iptables firewall** — outbound traffic limited to GitHub, npm/PyPI/crates.io, and Anthropic APIs. Everything else is blocked and verified at startup.
- **Non-root user** — runs as `node` (UID 1000), not root
- **Bind-mounted workspace** — only your project directory is accessible, not your whole filesystem
- **Composable language stacks** — pick what you need: `node`, `rust`, `python`, `go`, or combine them

## Quick Start

```bash
# Clone the template (once)
git clone https://github.com/a1f/claude-devcontainer-template.git ~/.cc-template
~/.cc-template/cc install   # symlinks 'cc' into ~/bin

# Set up a project
cd ~/dev/my-project
cc init --stack rust         # or: node, python, go, rust,python
cc build
cc start

# Work
cc claude                    # launches Claude (skip-permissions mode)
cc shell                     # interactive shell in the container
```

## Commands

| Command | Description |
|---------|-------------|
| `cc init --stack <name>` | Scaffold `.devcontainer/` in current repo |
| `cc build` | Build the Docker image |
| `cc start` | Start container (mounts workspace, sets up firewall) |
| `cc claude [branch]` | Launch Claude inside the container |
| `cc shell [branch]` | Open bash in the container |
| `cc stop` | Stop and remove the container |
| `cc rebuild` | Stop + build + start |
| `cc status` | List all running `cc` containers |
| `cc urls` | Show forwarded port URLs |
| `cc install` | Symlink `cc` into `~/bin` |

### Worktrees (parallel branches)

```bash
cc worktree add feature-x    # create worktree + branch inside container
cc claude feature-x           # run Claude in that worktree
cc shell feature-x            # shell into worktree
cc worktree list              # list active worktrees
cc worktree remove feature-x  # clean up
```

## Stacks

Stacks are Dockerfile overlays appended to a common base image (node:20 + git, tmux, ripgrep, gh, etc.).

| Stack | What it adds | Firewall domains |
|-------|-------------|-----------------|
| `node` | Nothing (base already has Node 20) | — |
| `rust` | rustup + stable toolchain, cargo-watch | crates.io, static.crates.io |
| `python` | python3, pip, uv | pypi.org, files.pythonhosted.org |
| `go` | Go 1.23 | proxy.golang.org, sum.golang.org |

Combine stacks: `cc init --stack rust,python`

## How the Firewall Works

On container start, `init-firewall.sh` runs with `sudo` and:

1. Fetches GitHub's IP ranges from `api.github.com/meta`
2. Resolves a hardcoded allowlist (npm, Anthropic API, Sentry, VS Code Marketplace)
3. Loads per-repo extra domains from `.devcontainer/firewall-extra-domains.txt`
4. Sets iptables default policy to **DROP** for all outbound
5. Allows only resolved IPs via an `ipset`
6. Verifies by confirming `example.com` is blocked and `api.github.com` is reachable

## Configuration

After `cc init`, edit `.devcontainer/cc.conf`:

```bash
STACK=rust
CONTAINER_NAME=cc-my-project
PORTS="3000:3000 5173:5173"          # host:container port mappings
EXTRA_FIREWALL_DOMAINS=""             # additional domains to allow
EXTRA_APT=""                          # additional apt packages
CLAUDE_FLAGS="--dangerously-skip-permissions"
```

To allow additional domains, either edit `cc.conf` and rebuild, or add them to `.devcontainer/firewall-extra-domains.txt` (one per line).

## Environment Variables

| Variable | Purpose |
|----------|---------|
| `ANTHROPIC_API_KEY` | Passed into container for Claude auth |
| `GH_TOKEN` | Passed into container for GitHub CLI |
| `CC_TEMPLATE_DIR` | Override template location (default: where `cc` lives) |

## Adding a Custom Stack

Create `stacks/<name>.Dockerfile`:

```dockerfile
# My custom stack overlay
# Extra firewall domains: example.com api.example.com

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  my-package \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
USER node
```

The `# Extra firewall domains:` comment is parsed by `cc init` to auto-populate firewall rules.

## VS Code Devcontainer

The generated `.devcontainer/devcontainer.json` works with VS Code's Dev Containers extension. Open the project folder and select "Reopen in Container" — the firewall and Claude Code are set up automatically via `postStartCommand`.

## License

MIT
