## What is it ?

**_dev-env-core_** is a tool that setup a development environment on a linux based OS.

The core version is a minimalist non intrusive version :
1. It applies a minimalist set of dotfiles templates (i3, tmux, git, bash aliases, git bash prompt, bash completions)
1. It install only a minimal set of tools on system : tmux

#### Supported systems

- Manjaro i3

The tools has been tested on `Manjaro Linux` i3 distribution

## Install prerequisites

The tool is based on ansible. Which allow to be launched several time without doing all tasks that have been already done.

```bash
pacman -S ansible
```

## Install

#### Fill your variables

Fills the variables in vars.yml

```bash
cp vars_example.yml vars.yml
vi vars.yml
```

#### Run the install

```bash
./install.sh
```

## Credits

This tool is greatly inspired from
- Michaël Bitard works (tmux conf, bash aliases, ansible base)
- Development environment setup and good practices @ LivingObjects
