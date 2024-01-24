#!/bin/bash

SRC_DIR="/usr/share/perl5/PVE/LXC"
SETUP_FILE="${SRC_DIR}/Setup.pm"
CLEARLINUX_FILE="${SRC_DIR}/Setup/ClearLinux.pm"


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

# dependency checks
hash sed 2>/dev/null || { 
    echo -e >&2 "${REDB}[ERROR] sed is required but missing${CR}";
    exit 1;
}
echo -e "${GRN}${CHECKMARK} sed available${CR}"

hash pveversion 2>/dev/null || { 
    echo -e >&2 "${REDB}[ERROR ]Proxmox not found? Why you even want this?${CR}";
    exit 1;
}
echo -e "${GRN}${CHECKMARK} Proxmox installed${CR}"

PVE_VERSION=$(pveversion --verbose | grep pve-manager | cut -c 14- | cut -c -6) # Below pveversion pre-run check
PVE_VERSION_MAJOR=$(echo $PVE_VERSION | cut -d'.' -f1)
PVE_VERSION_MINOR=$(echo $PVE_VERSION | cut -d'.' -f2)
PVE_VERSION_PATCH=$(echo $PVE_VERSION | cut -d'.' -f3)

if ! grep -q clear-linux-os "$SETUP_FILE"; then
    # backup Setup.pm
    cp $SETUP_FILE $SETUP_FILE.bak

    # alter Setup.pm
    $SUDO sed -i '/^use PVE::LXC::Setup::NixOS;.*/a use PVE::LXC::Setup::ClearLinux;' $SETUP_FILE
    $SUDO sed -i $'/.*unmanaged =>.*/i \'clear-linux-os\' => \'PVE::LXC::Setup::ClearLinux\',' $SETUP_FILE
    $SUDO sed -i $'/.*unmanaged =>.*/i clear => \'PVE::LXC::Setup::ClearLinux\',' $SETUP_FILE

    echo -e "${GRN}${CHECKMARK} patched Setup.pm${CR}"
fi

if test -f "$CLEARLINUX_FILE"; then
   $SUDO rm -f "${CLEARLINUX_FILE}"
   echo -e "${GRN}${CHECKMARK} removed old Clearlinux.pm file ${CR}"
fi

$SUDO curl "https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/src/Setup/ClearLinux.pm" -o $CLEARLINUX_FILE

PVEMANAGER_STATUS=$(systemctl status pve-manager | grep "Active:" | awk '{print $2}')

if [ "$PVEMANAGER_STATUS" -eq "active"]
then
   $SUDO systemctl restart pvedaemon.service
   echo -e "${GRN}${CHECKMARK} pve-manager restarted, changes now active ${CR}"
fi

echo -e "${GRN}${CHECKMARK} Successfully patched pve ${CR}"
