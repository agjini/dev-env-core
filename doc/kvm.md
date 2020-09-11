# Use KVM (qemu) on Manjaro:
## Install properly KVM:
Before you follow the doc below be aware that:
- This part is not needed anymore:
```bash
sudo pacman -S yaourt
yaourt -S --noconfirm --needed libguestfs
```
- Instead you can easily install "libguestfs" from the official repositories in Package Manager (like pamac), or via pacman:
```bash
sudo pacman -S libguestfs
```
For the rest, just follow this doc, it's awesome:
- https://computingforgeeks.com/complete-installation-of-kvmqemu-and-virt-manager-on-arch-linux-and-manjaro/

## Create your VM:

### OEM Windows key recovery
If you installed Manjaro on a Windows 10 OS, you may get back the OEM Windows key with the following command:
```bash
sudo strings /sys/firmware/acpi/tables/MSDM | tail -c 30
```
And then, you can use it for a Windows VM.

### Network:

- You'll need to select (in hardware: NIC:8d:68:92 for example):
    - Network source: Virtual network 'default': NAT
    - Source mode: Bridge
    - Device Model: e1000e

#### Troubleshooting:

If this Network source does not work (no internet access), it might probably works with: 
- Network source: Host device eno2: macvtap

BUT you'll need to select "Virtual network 'default': NAT" later to be able to ping your guest from host.
- When selecting NAT if it's described as:
    - Virtual network 'default'(inactive): NAT => network default is not active
Check if it is activated (don't forget 'sudo', the list will be empty otherwise):
```bash
sudo virsh net-list --all
```
You will see something like this:
```
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes
```
Now, you will have to look to the columns 'State' and 'Autostart':
- If the 'State' column for the 'default' line si set to 'inactive', then you have to start it, you need to run:
```bash
sudo virsh net-start default
```
So now, you will be able to choose the virtual network 'default' for your VM.

- If the 'Autostart' column for the 'default' line is set to 'no', then you have to autostart it, you need to run:
```bash
sudo virsh net-autostart default
```
So now, 'default' network will start automatically on boot.

### Copy-paste Host <=> Guest:
- Install https://www.spice-space.org/downloads/binaries/spice-guest-tools/ lastest version
Mine is 2018-01-04 not so up to date but works perfectly