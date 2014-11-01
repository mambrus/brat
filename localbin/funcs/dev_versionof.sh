# Returns version and SHA1-1 (if applicable) of a particular component of
# bladerd device.
#
# The format returned should be identical to the format of
# git_list_all_versionsof.
#
# The _required_ arguments(s) should be identical to the arguments for
# git_list_all_versionsof.
#
# Arguments:
# 1) required: String "firmware" or "fpga"

function dev_versionsof() {
	local TYPE=$1
	case $TYPE in
	firmware)
		local GLINE="Firmware version"
		;;
	fpga)
		local GLINE="FPGA version"
		;;
	?)
		echo "Bad argument #1 to $0: [$1]" 1>&2
		return 1
		;;
	esac

	RS=$(
		(bladeRF-cli -e 2>/dev/null 'version') | \
		grep "$GLINE" | \
		cut -f2 -d":" | \
		awk '{print $1}';
	)
	local VERSION=$(awk -F'-' '{print $1}'  <<< $RS)
	local SHA1=$(awk -F'-' '{print $3}'  <<< $RS)
	echo "$SHA1 v$VERSION"

}
