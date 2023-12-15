#!/bin/bash

$ctid=88012
$hostname"clearlinux-final"
$template="ClearLinux-40450-x86_64-final.tar.gz"

systemctl restart pvedaemon.service
pct create $ctid \
	/var/lib/vz/template/cache/$template \
	-hostname $hostname \
	-features nesting=1 \
	-storage local-zfs \
	-timezone host \
	-net0 name=eth0,bridge=vmbr0,ip=dhcp \
	--cmode shell
