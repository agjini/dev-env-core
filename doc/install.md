
## Install prerequisites

The tool is based on ansible. Which allow to be launched several time without doing all tasks that have been already done.

```bash
pacman -S ansible
```

## Install

#### Fill your variables

Fills the variables in vars.yml (In the project directory)

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

## Classical manjaro installation steps done after the core install :

### Disable speaker

```bash
sudo rmmod pcspkr
sudo echo blacklist pcspkr >> /etc/modprobe.d/nobeep.conf
```

The second line may not work with the following error:
```bash
-bash: /etc/modprobe.d/nobeep.conf: Permission denied
````
Why ? Because the command behind the redirection '>>' is done as a regular user.
Then you need to execute this instead:
```bash
sudo sh -c "echo 'blacklist pcspkr' >> /etc/modprobe.d/nobeep.conf"
```
OR
```bash
echo 'blacklist pcspkr | sudo tee -a /etc/modprobe.d/nobeep.conf
```
'tee' command is very powerful for this kind of works.
It reads data from stadard input and write to standard output and files.

### Install pulseaudio

install_pulse

In sound tray icon set `pavucontrol` as mixer

### Install following software :

Enable AUR in pamac

- nvm
- docker
- vscode
- kvm (for running virtual machine), see https://github.com/Retaildrive/devops/blob/master/doc/kvm.md
