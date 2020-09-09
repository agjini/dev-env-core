# Use KVM (qemu) on Manjaro:
## Install properly KVM:
Before you follow the doc below be aware that:
- This part doesn't work:
```bash
sudo pacman -S yaourt
yaourt -S --noconfirm --needed libguestfs
```
- You can easiely install "libguestfs" from AUR source in Package Manager UI instead, it doesn't work for me from Yaourt :( 
For the rest, just follow this doc, it's awesome:
- https://computingforgeeks.com/complete-installation-of-kvmqemu-and-virt-manager-on-arch-linux-and-manjaro/

## Create your VM:
### Network:

- You'll need to select (in hardware: NIC:8d:68:92 for example):
    - Network source: Virtual network 'default': NAT
    - Source mode: Bridge
    - Device Model: e1000e

#### Troubleshoot:

If this Network source does not work (no internet access), it might probably works with: 
- Network source: Host device eno2: macvtap

BUT you'll need to select "Virtual network 'default': NAT" later to be able to ping your guest from host.
- When selecting NAT if it's described as:
    - Virtual network 'default'(inactive): NAT => network default is not active
Check if it is activated:
```bash
sudo virsh net-list --all
```
If the list is empty, then run:
```bash
sudo virsh net-autostart default
```
To enable on PC start.

### Copy-paste Host <=> Guest:
- Install https://www.spice-space.org/downloads/binaries/spice-guest-tools/ lastest version
Mine is 2018-01-04 not so up to date but works perfectly