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
Default selected Network source doesn't work (for Windows 10 in my case)  
- You'll need to select (in hardware: NIC:8d:68:92 for example):
    - Network source: Host device eno2: macvtap
    - Source mode: Bridge
    - Device Model: e1000e

UPDATE: Then I move to:
- Network source: Virtual network 'default': NAT 
- And network(internet from host) works
- I can access my VM IP from the guest

