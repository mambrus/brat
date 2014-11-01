#! /bin/bash
# Updates the stash & update cross-match matrix.
# Downloads if needed, but tries not to

pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/local/envsetup.sh
popd >/dev/null

INCLUDE funcs

TYPE=$1
REQ_VERSION=$2
GIT_DIR=$3

case $TYPE in
firmware)
	TOOL="fw"
	;;
fpga)
	TOOL="fpga"
	;;
?)
	echo "Error: $(basename $0) expects first argument [\"firmware\"|\"fpga\"]" 1>&2
	return 1
	;;
esac

BRF_SHA1=$(git_getsha1 "$GIT_DIR")

if [ "X${REQ_VERSION}" == "X" ]; then
	BRF_VERSION=$(
	  git_list_all_versionsof $TYPE "$GIT_DIR" | \
	  head -n1 | awk '{print $2}')
else
	BRF_VERSION="$REQ_VERSION"
fi

if ! [ -d "$BRF_STASH_DIR" ]; then
	mkdir -p "$BRF_STASH_DIR"
fi
pushd "$BRF_STASH_DIR" >/dev/null

echo "Getting $TYPE for version [$BRF_VERSION]..."
DL_FILES=$(bladerf_get${TOOL}.sh "$BRF_VERSION")

if ! [ -d "$BRF_SHA1" ]; then
	mkdir $BRF_SHA1
fi

if [ $TOOL == "fw" ]; then
	FPGA_FW=$(echo $DL_FILES | sed -e 's/ /\n/' | grep _fw_)
else
	FPGA_X40=$(echo $DL_FILES | sed -e 's/ /\n/' | grep x40)
	FPGA_X115=$(echo $DL_FILES | sed -e 's/ /\n/' | grep x115)
fi

pushd $BRF_SHA1 >/dev/null

if [ $TOOL == "fw" ]; then
	ln -sf "../${FPGA_FW}"    "${FPGA_FW}"
else
	ln -sf "../${FPGA_X40}"   "${FPGA_X40}"
	ln -sf "../${FPGA_X115}"  "${FPGA_X115}"
fi

popd >/dev/null
popd >/dev/null
echo "Stashing $TYPE done..."
