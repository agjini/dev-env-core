## What is it ?

**_dev-env-core_** is a tool that setup a full stack development environment on a linux based OS.

The core version is a minimalist non intrusive version :
1. It apply a minimalist set of dotfiles templates
1. It install only a minimal set of tools on system : tmux

#### Supported systems

- Manjaro

The tools has been tested on `Manjaro i3`

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

After install you can add a `~/.ssh/config_perso` file with personal ssh aliases. It will be automatically included in `~/.ssh/config`.

## Credits

This tool is greatly inspired from
- Michaël Bitard works (tmux conf, bash aliases, ansible base)
- Development environment setup and good practices @ LivingObjects
