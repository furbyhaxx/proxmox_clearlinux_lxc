## What is this
<p>A patch for Proxmox which allows the use of ClearLinux LXC templates<br>
</p>

## Where do I get the LXC containers?
[LXC templates](https://github.com/furbyhaxx/clearlinux_lxc/)

## Tested on
Proxmox 8.1.3 but should at least work on all PVE 8 versions.

## Installation 
The installation is done via the CLI utility. Run the following commands on the PVE node.

```
wget https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/install.sh
bash install.sh
```
Or this one liner
```
curl -s https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/install.sh | bash
```

## Running as service
This automatically patches pve on every boot to stay active after updates.
```
~# wget https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/install-service.sh
~# bash install-service.sh
```
Or this one liner
```
curl -s https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/install-service.sh | bash
```

## Bugs
- Privileged containers need to manually set "nesting=1" or systemd is not working
- ~~Snapshots not working (GUI shows 'The current guest configuration does not support taking new snapshots')~~ fixed
- ~~cmode=shell is needed as it always created links to /dev/lxc/ttyN instead of /dev/ttyN and I have no idea why~~ the /etc/systemd/system/getty.target.wants/ folder was missing
