## What is this
<p>A patch for Proxmox which allows the use of ClearLinux LXC templates<br>
</p>
[LXC templates](https://github.com/furbyhaxx/clearlinux_lxc/)

## Tested on
Proxmox 8.1.3 but should at least work on all PVE 8 versions.

## Installation 
The installation is done via the CLI utility. Run the following commands on the PVE node.

```
~# wget https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/install.sh
~# bash install.sh
```
Or this one liner
```
bash <(curl -s https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/install.sh )
```
