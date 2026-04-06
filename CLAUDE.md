# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A CLI tool (`cc`) and template system for running Claude Code inside isolated Docker devcontainers with iptables-based network firewalling. The container runs Claude with `--dangerously-skip-permissions` safely by restricting outbound network access to an allowlist of domains.

## Architecture

The `cc` bash script is the single entry point. It scaffolds per-repo `.devcontainer/` directories by composing:

1. **`Dockerfile.base`** — Base image (node:20) with dev tools, Claude Code npm install, non-root `node` user, and firewall script setup
2. **`stacks/*.Dockerfile`** — Language overlays (rust, python, go, node) appended to the base. Each stack can declare `# Extra firewall domains:` in a comment header that `cc init` extracts automatically
3. **`init-firewall.sh`** — iptables firewall that drops all outbound except: GitHub IP ranges (fetched from `/meta` API), a hardcoded allowlist (npm, Anthropic, Sentry, VS Code), and per-repo extras from `firewall-extra-domains.txt`
4. **`devcontainer.json.template`** — VS Code devcontainer config with `__PORTS__` placeholder replaced at init time

`cc init --stack <name>` generates into the target repo: `Dockerfile`, `cc.conf`, `devcontainer.json`, `init-firewall.sh`, and optionally `firewall-extra-domains.txt`. Stacks are composable via comma separation (`--stack rust,python`).

## Key Commands

```bash
cc init --stack rust      # Scaffold .devcontainer/ in current repo
cc build                  # docker build from .devcontainer/
cc start                  # docker run with volume mounts, env vars, firewall init
cc shell [branch]         # exec bash in container (optionally in a worktree)
cc claude [branch]        # exec claude with CLAUDE_FLAGS from cc.conf
cc worktree add <branch>  # git worktree inside container for parallel branches
cc stop                   # stop + rm container
cc rebuild                # stop + build + start
cc install                # symlink cc into ~/bin
```

## Container Runtime Details

- Workspace mounted at `/workspace` (bind mount, delegated consistency)
- Bash history and `.claude` config persisted via named Docker volumes
- Requires `NET_ADMIN` + `NET_RAW` capabilities for iptables
- `ANTHROPIC_API_KEY` and `GH_TOKEN` passed from host environment
- Per-repo config lives in `.devcontainer/cc.conf` (sourced as bash vars: `CONTAINER_NAME`, `PORTS`, `EXTRA_FIREWALL_DOMAINS`, `CLAUDE_FLAGS`)

## Adding a New Stack

Create `stacks/<name>.Dockerfile`. Optionally add a `# Extra firewall domains:` comment on line 2 with space-separated domains. The overlay runs as the `node` user by default; switch to `USER root` for apt installs and back to `USER node` after.
