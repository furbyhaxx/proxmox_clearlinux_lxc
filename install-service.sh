#!/bin/bash

SCRIPT_PATH=/usr/share
SCRIPT_FILE=${SCRIPT_PATH}/pve-cc-patcher.sh
UNIT_PATH=/etc/systemd/system
UNIT_FILE=${UNIT_PATH}/pve-cclxc-patcher.service

# constants
RED='\033[0;31m'
REDB='\033[0;31m\033[1m'
GRN='\033[92m'
WARN='\033[93m'
BOLD='\033[1m'
CR='\033[0m'
CHECKMARK='\033[0;32m\xE2\x9C\x94\033[0m'

# sudo needed?
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

if ! [ -d ${SCRIPT_PATH} ]; then
    $SUDO mkdir -p $SCRIPT_PATH
fi

if ! [ -f ${SCRIPT_FILE} ]; then
    $SUDO curl "https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/pve-cc-patcher.sh" -o $SCRIPT_FILE
    $SUDO chmod +x ${SCRIPT_FILE}
fi

if [ -f $UNIT_FILE ]; then
   $SUDO systemctl disable pve-cclxc-patcher.service
   $SUDO systemctl stop pve-cclxc-patcher.service
   $SUDO rm -f $UNIT_FILE
fi

$SUDO tee -a "${UNIT_FILE}" >/dev/null <<-EOF
[Unit]
Description=Patch pve sources to allow clearlinux LXCs and persist after an update.
Before=pve-manager.service

[Service]
ExecStart=/usr/share/pve-cc-patcher.sh
RemainAfterExit=true
Type=oneshot

[Install]
WantedBy=multi-user.target
Alias=pve-cclxc-patcher.service
EOF

$SUDO systemctl daemon-reload
$SUDO systemctl enable --now pve-cclxc-patcher.service

