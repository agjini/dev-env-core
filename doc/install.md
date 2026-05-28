## Install prerequisites

The tool is based on [Comtrya](https://comtrya.dev/). It runs idempotent manifests so it can be replayed as many times as needed. `install.sh` will install Comtrya for you via `paru` (preinstalled on CachyOS).

## Install

#### Fill your variables

Fill in the variables in `vars.yml` (at the project root)

```bash
cp vars_example.yml vars.yml
$EDITOR vars.yml
```

#### Run the install

```bash
./install.sh
```

The script will:
1. `git pull` to fetch the latest manifests
2. Install `comtrya` via `cargo` if missing
3. Parse `vars.yml` into `-D key=value` flags
4. Run `comtrya apply` — packages are installed via `paru` (sudo prompt) and dotfiles are written to `~`

## Credits

This tool is greatly inspired from
- Michaël Bitard works (tmux conf, bash aliases)
- Development environment setup and good practices @ LivingObjects & Synergee
