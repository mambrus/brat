#! /bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/envsetup.sh
popd >/dev/null

TS=$(date '+%y%m%d_%H%M%S')

if [ "X$1" == "X" ]; then
	BRF_FPGAVERSION=$(bladerf_qryver_git.sh fpga)
else
	BRF_FPGAVERSION=$1
fi

BRF_FPGANAME_1="hostedx40.rbf"
BRF_FPGANAME_2="hostedx115.rbf"

BRF_TDIR="/tmp/bladerf_${TS}"
mkdir -p $BRF_TDIR

function download() {
	local BRF_FPGANAME=$1
	pushd $BRF_TDIR >/dev/null
	wget --quiet "${BRF_SERVER}/${BRF_FPGADIR}/${BRF_FPGAVERSION}/${BRF_FPGANAME}"
	popd >/dev/null
}

OUTF_1="$(echo $BRF_FPGANAME_1 | cut -f1 -d".")_${BRF_FPGAVERSION}.rbf"
OUTF_2="$(echo $BRF_FPGANAME_2 | cut -f1 -d".")_${BRF_FPGAVERSION}.rbf"
OUTF_1=$(echo $OUTF_1  | sed -e 's/hosted/bladeRF_fpga_/')
OUTF_2=$(echo $OUTF_2  | sed -e 's/hosted/bladeRF_fpga_/')

if [ -f "${OUTF_1}" ]; then
	echo "${OUTF_1} exists. Skipping..." 1>&2
else
	download $BRF_FPGANAME_1
	cp "${BRF_TDIR}/${BRF_FPGANAME_1}" "$OUTF_1"
fi

if [ -f "${OUTF_2}" ]; then
	echo "${OUTF_2} exists. Skipping..." 1>&2
else
	download $BRF_FPGANAME_2
	cp "${BRF_TDIR}/${BRF_FPGANAME_2}" "$OUTF_2"
fi

rm -rf "$BRF_TDIR"

ls "$OUTF_1"
ls "$OUTF_2"


