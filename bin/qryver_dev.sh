#! /bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/../local/envsetup.sh
popd >/dev/null

INCLUDE funcs

TYPE=$1

DEV_SERIAL=$(bladeRF-cli -p 2>/dev/null | grep Serial | awk '{print $2}')
DEV_ATTACHED=$(bladeRF-cli -p 2>&1 | grep "No device")


if [ "X${DEV_ATTACHED}" != "X" ] || [ "X${DEV_SERIAL}" == "X" ]; then
	echo "Device error: ${DEV_ATTACHED} ${DEV_SERIAL}" 1>&2
	exit 1
fi

if [ "X${1}" == "Xfpga" ]; then
	dev_versionsof $TYPE | head -n1 | awk '{print $1}'
elif [ "X${1}" == "Xfirmware" ]; then
	dev_versionsof $TYPE | head -n1 | awk '{print $2}'
else
	echo "Error: $(basename $0) expects one argument [\"firmware\"|\"fpga\"]" 1>&2
	exit 1
fi

