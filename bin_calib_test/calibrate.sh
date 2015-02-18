#! /bin/bash

if [ $# -gt 1 ]; then
	echo "ERROR: $(basename $(readlink -f $0) takes/need one"\
			"or none argument only (SID))" 1>&2
	exit
fi

TIMESTAMPS=${TIMESTAMPS-"yes"}
BLADERF_LOG_LEVEL=${BLADERF_LOG_LEVEL-"warning"}
export BLADERF_LOG_LEVEL

SERIAL=${SERIAL-$1}

function doit_wiS() {
	if [ "X${TIMESTAMPS}" == "Xyes" ]; then
		echo -n ">>>TIMESTAMP: "
		date +"%D %T"
	fi
	echo bladeRF-cli -d \"${SERIAL}\" -v $BLADERF_LOG_LEVEL -e \"${@}\"
	ARGS="${@}"
	bladeRF-cli -d "${SERIAL}" -v $BLADERF_LOG_LEVEL -e "$ARGS"
	let -i rc=$?
	#echo "------- $rc"
	if [ ! $rc -eq 0 ]; then
		echo "Operation failed..." 1>&2
		exit $rc;
	fi
}

function doit_noS() {
	if [ "X${TIMESTAMPS}" == "Xyes" ]; then
		echo -n ">>>TIMESTAMP: "
		date +"%D %T"
	fi
	echo bladeRF-cli -v $BLADERF_LOG_LEVEL -e \"${@}\"
	ARGS="${@}"
	bladeRF-cli -v $BLADERF_LOG_LEVEL -e "$ARGS"
	let -i rc=$?
	#echo "------- $rc"
	if [ ! $rc -eq 0 ]; then
		echo "Operation failed..." 1>&2
		exit $rc;
	fi
}

function doit() {
	if [ "X${SERIAL}" == "X" ]; then
		doit_noS "${@}"
	else
		doit_wiS "${@}"
	fi
}

ulimit -c unlimited
CURR_CORE_PATT=$(cat /proc/sys/kernel/core_pattern)
if [ "X${CURR_CORE_PATT::4}" != "Xcore" ]; then
	echo "Adjustment of proc/sys/kernel/core_pattern needed" 1>&2
	echo "core.%e" | sudo dd of=/proc/sys/kernel/core_pattern
fi

doit set frequency tx 900.401MHz
doit set frequency rx 945.401MHz
doit print rxvga2
doit set rxvga2 8
doit cal lms
doit cal dc rx
doit cal table dc rx
doit cal dc tx
doit cal table dc tx
