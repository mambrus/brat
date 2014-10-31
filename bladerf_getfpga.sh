#! /bin/bash
BRF_SERVER=https://www.nuand.com
BRF_FPGADIR=fpga
TS=$(date '+%y%m%d_%H%M%S')

#https://www.nuand.com/fpga/v0.1.1/hostedx40.rbf

pushd $(dirname $(readlink -f $0)) >/dev/null
export PATH=$(pwd):$PATH
popd >/dev/null

BRF_FPGAVERSION=$(bladerf_qryfpga.sh)

BRF_FPGANAME_1="hostedx40.rbf"
BRF_FPGANAME_2="hostedx115.rbf"

BRF_TDIR="/tmp/bladerf_${TS}"
mkdir -p $BRF_TDIR

pushd $BRF_TDIR >/dev/null
wget --quiet "${BRF_SERVER}/${BRF_FPGADIR}/${BRF_FPGAVERSION}/${BRF_FPGANAME_1}"
wget --quiet "${BRF_SERVER}/${BRF_FPGADIR}/${BRF_FPGAVERSION}/${BRF_FPGANAME_2}"
popd >/dev/null

OUTF_1="$(echo $BRF_FPGANAME_1 | cut -f1 -d".")_${BRF_FPGAVERSION}.rbf"
OUTF_2="$(echo $BRF_FPGANAME_2 | cut -f1 -d".")_${BRF_FPGAVERSION}.rbf"
OUTF_1=$(echo $OUTF_1  | sed -e 's/hosted/bladeRF_fpga_/')
OUTF_2=$(echo $OUTF_2  | sed -e 's/hosted/bladeRF_fpga_/')


cp "${BRF_TDIR}/${BRF_FPGANAME_1}" "$OUTF_1"
cp "${BRF_TDIR}/${BRF_FPGANAME_2}" "$OUTF_2"

ls "$OUTF_1"
ls "$OUTF_2"


