#!/usr/bin/env sh

if ! ip route list exact 192.168.161.0/24 | grep -q '^192.168.161.0/24'; then
	exit 0
fi

# sshfs
if mount | grep -q '/home/builder type autofs'; then
	ssh work cat /home/builder/SDKS/SSD/APPLY/DIR_QEMU_DBG/output/build/deuteron-master/dm/dm/dm_version.dm 2>/dev/null
else
	cat /home/builder/SDKS/SSD/APPLY/DIR_QEMU_DBG/output/build/deuteron-master/dm/dm/dm_version.dm 2>/dev/null
fi
