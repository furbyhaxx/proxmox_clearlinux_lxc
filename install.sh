#/bin/bash

ROOT_DIR="/usr/share/perl5/PVE/LXC"
SETUP_FILE="$ROOT_DIR/Setup.pm"
CLEARLINUX_FILE="$ROOT_DIR/Setup/ClearLinux.pm"

# checks, borrowed from https://github.com/Weilbyte/PVEDiscordDark/blob/master/PVEDiscordDark.sh
if [[ $EUID -ne 0 ]]; then
    echo -e >&2 "${BRED}Root privileges are required to perform this operation${REG}";
    exit 1
fi

hash sed 2>/dev/null || { 
    echo -e >&2 "${BRED}sed is required but missing from your system${REG}";
    exit 1;
}

hash pveversion 2>/dev/null || { 
    echo -e >&2 "${BRED}PVE installation required but missing from your system${REG}";
    exit 1;
}

PVEVersion=$(pveversion --verbose | grep pve-manager | cut -c 14- | cut -c -6) # Below pveversion pre-run check
PVEVersionMajor=$(echo $PVEVersion | cut -d'-' -f1)

if ! grep -q clear-linux-os "$SETUP_FILE"; then
    # backup Setup.pm
    cp $SETUP_FILE $SETUP_FILE.bak

    # alter Setup.pm
    sed -i '/^use PVE::LXC::Setup::NixOS;.*/a use PVE::LXC::Setup::ClearLinux;' $SETUP_FILE
    sed -i $'/.*unmanaged =>.*/i \'clear-linux-os\' => \'PVE::LXC::Setup::ClearLinux\',' $SETUP_FILE
    sed -i $'/.*unmanaged =>.*/i clear => \'PVE::LXC::Setup::ClearLinux\',' $SETUP_FILE
fi

if ! test -f "$CLEARLINUX_FILE"; then
    # copy ClearLinux.pm
    curl "https://raw.githubusercontent.com/furbyhaxx/proxmox_clearlinux_lxc/main/src/Setup/ClearLinux.pm" -o $CLEARLINUX_FILE
fi

# restart pve-manager to use changes
systemctl restart pvedaemon.service

echo "Installed"