#! /bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/localbin/envsetup.sh
popd >/dev/null

source ${BRF_DIR}/localbin/funcs/*.sh

TYPE=$1

if [ "X${1}" == "Xfpga" ] || [ "X${1}" == "Xfirmware" ]; then
	git_list_all_versionsof $TYPE | head -n1 | awk '{print $2}'
else
	echo "Error: $(basename $0) expects one argument [firmware|fpga]" 1>&2
	exit 1
fi

