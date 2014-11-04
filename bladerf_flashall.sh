#! /bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/local/envsetup.sh
popd >/dev/null

INCLUDE funcs

GIT_DIR=$1

set -e
BRF_SHA1=$(git_getsha1 "$GIT_DIR")
BLADE_SZ=$(dev_size)
set +e

GIT_FPGA_VER_S=$(git_list_all_versionsof fpga "$GIT_DIR" | awk '{print $2}' | head -n1)
DEV_FPGA_VER_S=$(dev_versionsof fpga "$GIT_DIR" | awk '{print $1}')
GIT_FW_VER_S=$(git_list_all_versionsof firmware "$GIT_DIR" | head -n1)
DEV_FW_VER_S=$(dev_versionsof firmware)

GIT_FPGA_VER=$GIT_FPGA_VER_S
DEV_FPGA_VER=$DEV_FPGA_VER_S
GIT_FW_VER=$(awk '{print $2}' <<< $GIT_FW_VER_S)
DEV_FW_VER=$(awk '{print $2}' <<< $DEV_FW_VER_S)

FPGA_DIFFERS=no
FW_DIFFERS=no

if [ "X$GIT_FPGA_VER_S" != "X$DEV_FPGA_VER_S" ]; then
	FPGA_DIFFERS=yes
	FPGA_MARK='(*)'
fi
if [ "X$GIT_FW_VER_S" != "X$DEV_FW_VER_S" ]; then
	FW_DIFFERS=yes
	FW_MARK='(*)'
fi

if [ "X$BRF_VERBOSE" == "Xyes" ]; then
	echo "FPGA version-check $FPGA_MARK"
	echo "  Req: $GIT_FPGA_VER_S"
	echo "  Dev: $DEV_FPGA_VER_S"
	echo
	echo "FW version-check (full) $FW_MARK"
	echo "  Req: $GIT_FW_VER_S"
	echo "  Dev: $DEV_FW_VER_S"
	echo
	echo "FW version-check $FW_MARK"
	echo "  Req: $GIT_FW_VER"
	echo "  Dev: $DEV_FW_VER"
	echo
fi

bladerf_stash.sh firmware $GIT_FW_VER "$GIT_DIR"
bladerf_stash.sh fpga $GIT_FPGA_VER "$GIT_DIR"

pushd "$BRF_STASH_DIR" >/dev/null
pushd $BRF_SHA1 >/dev/null

echo
if [ "${FPGA_DIFFERS}" == "yes" ]; then
	echo "Flashing FPGA. Please wait..."
	if [ "x${BLADE_SZ}" == "x40" ]; then
		bladeRF-cli -L bladeRF_fpga_x40_*.rbf
	elif [ "x${BLADE_SZ}" == "x115" ]; then
		bladeRF-cli -L bladeRF_fpga_x115_*.rbf
	fi
else
	echo "*** Flashing FPGA skipped"
fi

if [ "${FW_DIFFERS}" == "yes" ]; then
	echo "Flashing FW. Do not interrupt flashing. Please wait..."
	bladeRF-cli -f bladeRF_fw_*.img
else
	echo "*** Flashing FW skipped"
fi

popd >/dev/null
popd >/dev/null
echo "All done!"

