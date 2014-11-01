#! /bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/envsetup.sh
popd >/dev/null

if [ "X$1" == "X" ]; then
	BRF_FWVERSION=$(bladerf_qryver_git.sh firmware)
else
	BRF_FWVERSION=$1
fi

BRF_FWNAME=bladeRF_fw_${BRF_FWVERSION}.img

if [ -f "${BRF_FWNAME}" ]; then
	echo "${BRF_FWNAME} exists. Skipping..." 1>&2
else
	wget --quiet "${BRF_SERVER}/${BRF_FX3DIR}/${BRF_FWNAME}"
fi

ls "${BRF_FWNAME}"
