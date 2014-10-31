#! /bin/bash
BRF_SERVER=https://www.nuand.com
BRF_FX3DIR=fx3

pushd $(dirname $(readlink -f $0)) >/dev/null
export PATH=$(pwd):$PATH
popd >/dev/null

BRF_FWNAME=bladeRF_fw_$(bladerf_qryfw.sh).img

wget --quiet "${BRF_SERVER}/${BRF_FX3DIR}/${BRF_FWNAME}"
ls "${BRF_FWNAME}"
