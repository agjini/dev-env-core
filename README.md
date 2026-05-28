## What is it ?

**_dev-env-core_** is a tool that sets up a development environment on a Linux based OS.

The core version is a minimalist non intrusive version :
1. It applies a minimal set of dotfiles (fish, tmux, git)
1. It installs only a minimal set of tools on the system : tmux, httpie, jq, rio, noto-fonts-emoji, zoxide

#### Supported systems

- CachyOS (Arch-based)

## Getting started

1. [Install on CachyOS](./doc/install.md)
2. [Print the cheat sheet](./doc/cheatsheet.md) (pour générer un pdf : `npx md-to-pdf --pdf-options '{"margin": "15mm 15mm"}' cheatsheet.md`)
3. [Troubleshooting](./doc/troubleshooting.md)

## How it works

The provisioning is driven by [Comtrya](https://comtrya.dev/) :
- `Comtrya.yaml` — root config (manifest paths + default variables)
- `manifests/` — manifests describing actions (`tools.yaml`, `dotfiles.yaml`)
- `manifests/files/` — dotfile sources (rendered with Tera when `template: true`)
- `install.sh` — bootstraps comtrya via paru, then runs `comtrya apply`
