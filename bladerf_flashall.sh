#! /bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/localbin/envsetup.sh
popd >/dev/null

set -o pipefail
exec 3>&1 4>&2 1>/dev/null 2>/dev/null
if ! git remote -v | grep bladeRF.git | wc -l; then
	exec 1>&3- 2>&4-
	echo "You don't seem to be executing somewhere from withing BladeRF src-dir" 1>&2
	exit 1
fi
exec 1>&3- 2>&4-

BRF_SHA1=$(git log --oneline | head -n1 | awk '{print $1}')
BRF_FPGAVERSION=$(bladerf_qryver_git.sh fpga)
BRF_FWVERSION=$(bladerf_qryver_git.sh firmware)
BLADE_SZ=$((bladeRF-cli -e 'info' 2>/dev/null) | grep 'FPGA size' | awk '{print $3 }')

if [ ! "x${BLADE_SZ}" == "x40" ] && [ ! "X${BLADE_SZ}" == "x115" ]; then
	echo "Can't communicate with tranciever (Err=${BLADE_SZ}). Is it attached?" 1>&2
	exit 1
fi

if ! [ -d "$BRF_STASH_DIR" ]; then
	mkdir -p "$BRF_STASH_DIR"
fi

pushd "$BRF_STASH_DIR" >/dev/null


echo "Getting FPGAs..."
FPGA_FILES=$(bladerf_getfpga.sh "$BRF_FPGAVERSION")
echo "Getting FW..."
FW_FILES=$(bladerf_getfw.sh "$BRF_FWVERSION")

if ! [ -d "$BRF_SHA1" ]; then
	mkdir $BRF_SHA1
fi

FPGA_X40=$(echo $FPGA_FILES | sed -e 's/ /\n/' | grep x40)
FPGA_X115=$(echo $FPGA_FILES | sed -e 's/ /\n/' | grep x115)
FPGA_FW=$(echo $FW_FILES | sed -e 's/ /\n/' | grep _fw_)

pushd $BRF_SHA1 >/dev/null
ln -sf "../${FPGA_X40}"   "${FPGA_X40}"
ln -sf "../${FPGA_X115}"  "${FPGA_X115}"
ln -sf "../${FPGA_FW}"    "${FPGA_FW}"

echo "Flashing FPGA. Please wait..."
if [ "x${BLADE_SZ}" == "x40" ]; then
	bladeRF-cli -L bladeRF_fpga_x40_*.rbf
elif [ "x${BLADE_SZ}" == "x115" ]; then
	bladeRF-cli -L bladeRF_fpga_x115_*.rbf
fi


echo "Flashing FW. Please wait..."
bladeRF-cli bladeRF_fw_*.img

popd >/dev/null

popd  >/dev/null
echo "All done!"

