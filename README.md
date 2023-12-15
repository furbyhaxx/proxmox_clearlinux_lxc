# path to overwrite
/usr/share/perl5/PVE/LXC/

tested on pve 8.1.3

need to write a script to change the pve files

generate a rootfs tarball with clearlinux_lxc and place it at /var/lib/vz/template/cache/

as far as I tested, everything works except the tty from the web ui, pct enter works. create the CT from the commandline like in the script ct_create.sh

