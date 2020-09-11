# Troobleshooting:

## Error 'you need to load the kernel first'

### Description
This problem may appear at the boot when GRUB tries to load the kernel and
you will have a black screen with the following lines on it:
```bash
error: file '/boot/vmlinuz-X.X-x86-64' not found.
error: you need to load the kernel first.
```

### Analysis
Basically, GRUB can't find the kernel. Why ? Because it doesn't exist anymore, or GRUB doesn't look for the good one.
In my case, the kernel was not here anymore after an update and I still don't know why.
So I just install a new one to make GRUB happy again.

### Recovery
First of all, I will say that you should try to change the GRUB configuration to load an other kernel than the one it tries to, sometimes it is just a GRUB configuration that is not working

But for me, I diagnotised that my kernel was deleted and so even 'mkinitcpio' command can't do anything to help me...

That said, let's dive into what I have found !

Prerequisite:
- Linux distro live on a USB or HDD or anything to boot on
- Internet connection to install a new kernel via pacman

1. Open a terminal

2. We need to have the super user privileges, so we enter the following command:
```bash
su
```

3. We create a new directory in the '/mnt' directory. You can name it whatever you want. For the following help, I called it 'Manjaro'.
So you will need to change the directory name 'Manjaro' with the one you choose. Then you need to change your working directory for the newly created.
Here is the command to do so:
```bash
mkdir /mnt/Manjaro && cd /mnt/Manjaro
```
OR this one if you prefer to have auto-completion:
```bash
mkdir /mnt/Manjaro
cd /mnt/Manjaro
```

4. Then we need to know where is installed the broken OS.
```bash
os-prober
```
You will have one or more lines, if you have multiple OSes installed.
Every line will be like this, more or less:
```bash
/dev/sdXY:Manjaro
```
X is for the drive name, and Y for the number of it.
Instead of 'sdXY', it can also look like 'nvme.....' or other things.

5. After that, we need to mount the system directories to fix them.
Replace 'sdXY' with the one for your OS.
```bash
mount /dev/sdXY /mnt/Manjaro
mount -t proc proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/
```

6. We change the root directory so we are in the broken OS, like this:
```bash
chroot /mnt/Manjaro
```

7. If there is a file 'db.lck' in the '/var/lib/pacman' directory, we need to remove it to enable the updates via pacman:
```bash
rm -f /var/lib/pacman/db.lck
```

8. Then we update the databases and packages already installed:
```bash
pacman -Syu
```
An timeout error might occur, if so, you need to change the '/etc/resolv.conf' file to enable the network.
To do so, we need to exit the 'chroot' and then copy the '/etc/resolv.conf' file from the live OS to the broken OS :
```bash
exit
cp /etc/resolv.conf /mnt/Manjaro/etc/resolv.conf
chroot /mnt/Manjaro
```
Now we should be able to update the databases and packages installed with:
```bash
pacman -Syu
```

9. We can try to install a new kernel (for me it was 'linux54' but you can change it for whatever kernel in the next commands) with the following command:
```bash
mhwd-kernel -i linux54
```

10. If the previous command worked without error, then you can reboot your computer.
Otherwise, if you have an error 'no targets specified', like I had, you need to install the kernel linux from pacman like so:
```bash
pacman -S linux54
```

Finally, you can see that GRUB should be updated, and you can now reboot your computer and enjoy.
```bash
reboot
```

If you find any typos or that it is unclear, do not hesitate to tell.