
## Install prerequisites

The tool is based on ansible. Which allow to be launched several time without doing all tasks that have been already done.

```bash
sudo pacman -S ansible
```

## Install

#### Fill your variables

Fills the variables in vars.yml (In the project directory)

```bash
cp vars_example.yml vars.yml
vi vars.yml
```
Basic commands for Vi :
```vi
:i => insertion mode, to write in the opened file
:w => write changes in the file
:q => quit vi, only if there is no change
:q! => discard changes and quit vi
:wq => write and quit
```

#### Run the install

```bash
./install.sh
```

## Credits

This tool is greatly inspired from
- Michaël Bitard works (tmux conf, bash aliases, ansible base)
- Development environment setup and good practices @ LivingObjects

## Classical manjaro installation steps done after the core install :

### Disable speaker

```bash
sudo rmmod pcspkr
sudo sh -c "echo 'blacklist pcspkr' >> /etc/modprobe.d/nobeep.conf"
```

### Install pulseaudio

install_pulse

In sound tray icon, open 'Preferences' from Sound Mixer, go to 'Status Icon' tab and set 'External mixer' to `pavucontrol`

### Install following software :

Enable AUR in pamac

- nvm
- docker
- vscode
- kvm (for running virtual machine), see https://github.com/Retaildrive/devops/blob/master/doc/kvm.md
