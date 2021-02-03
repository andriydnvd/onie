#!/bin/sh
# Script to initialize the virtual machines system EEPROM.

. /etc/machine.conf

onie-syseeprom  | grep -q "Product Name"
rc=$?
if [ "$rc" -eq 0 ]; then
	tmp=$(onie-syseeprom -g 0x21 | awk '{print $1}')
	machine_model=$(echo "$tmp" | awk '{print tolower($0)}')
	if [ mlnx_"$machine_model" = "$onie_machine" ]; then
		exit 0
	fi
fi

echo "Initializing ONIE system EEPROM..."
onie-syseeprom -e

current_date=$(date +"%F-%T")
year=${current_date%%-*}
rest=${current_date#*-}
month=${rest%%-*}
rest=${rest#*-}
day=${rest%%-*}
rest=${rest#*-}
time=${rest%%}

if [ -z "$onie_machine_suffix" ] ; then
	machine_suffix="CD2F10"
else
	machine_suffix=$(echo "$onie_machine_suffix" | awk '{print toupper($onie_machine_suffix)}')
fi

if [ -z "$onie_base_mac" ] ; then
	base_mac="EC:0D:9A:10:20:30"
else
	base_mac=$(echo "$onie_base_mac" | awk '{print toupper($onie_base_mac)}')
fi

machine_model=$(echo "$onie_machine" | cut -b 6- | awk '{print toupper($onie_machine)}')


onie-syseeprom -s 0x21="$machine_model"
onie-syseeprom -s 0x22="$machine_model-$machine_suffix"
onie-syseeprom -s 0x23="MT${RANDOM}"
onie-syseeprom -s 0x24="$base_mac"
onie-syseeprom -s 0x25="${month}/${day}/${year} ${time}"
onie-syseeprom -s 0x26="16"
onie-syseeprom -s 0x28="$onie_platform"
onie-syseeprom -s 0x29="$onie_version"
onie-syseeprom -s 0x2a="128"
onie-syseeprom -s 0x2b="Mellanox"
onie-syseeprom -s 0x2d="Mellanox"
