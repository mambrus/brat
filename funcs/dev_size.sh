if [ "X${dev_size_sh}" != "Xy" ]; then
	dev_size_sh='y'

# Returns the fpga size of bladerf.
#
# Arguments: none
# 1) required: Stddring "firmware" or "fpga"

function dev_size() {
	local BLADE_SZ=$((bladeRF-cli -e 'info' 2>/dev/null) | \
		grep 'FPGA size' | \
		awk '{print $3 }')

    if [ ! "x${BLADE_SZ}" == "x40" ] && [ ! "X${BLADE_SZ}" == "x115" ]; then
		echo "Can't communicate with tranciever (Err=${BLADE_SZ}). Is it attached?" 1>&2
		exit 1
	fi

	echo $BLADE_SZ
}

fi
