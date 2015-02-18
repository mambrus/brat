#!/bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/../local/envsetup.sh
popd >/dev/null

if [ $# -gt 1 ]; then
	echo "ERROR: $(basename $(readlink -f $0)) takes/need one  or none argument only (SID)" 1>&2
	echo "  you sent $# in [${@}]"
	exit
fi

export BLADERF_LOG_LEVEL="debug"
export SERIAL=${1}

#Create filename for log of FS-legal characters
LOGNAME=$(echo "${SERIAL}_$(date +"%s").log" |
	tr ' ' '_' | \
	tr ':' '%' | \
	tr '=' '@' | \
	tr '*' '#' )

ulimit -c unlimited
CURR_CORE_PATT=$(cat /proc/sys/kernel/core_pattern)
if [ "X${CURR_CORE_PATT::4}" != "Xcore" ]; then
	echo "Adjustment of proc/sys/kernel/core_pattern needed" 1>&2
	echo "core.%e" | sudo dd of=/proc/sys/kernel/core_pattern
fi

function testloop() {
	for (( i=0; 1 ; i++)); do
		echo
		echo "**********************";
		echo $i;
		date +"%D %T"
		echo "**********************";
		calibrate.sh "${@}"
		sleep 100;
	done
}

( testloop 2>&1 ) | tee "${LOGNAME}"
