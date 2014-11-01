#! /bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/envsetup.sh
popd >/dev/null

set -o pipefail
exec 3>&1 4>&2 1>/dev/null 2>/dev/null
if ! git remote -v | grep bladeRF.git | wc -l; then
	exec 1>&3- 2>&4-
	echo "You don't seem to be executing somewhere from withing BladeRF src-dir" 1>&2
	exit 1
fi
exec 1>&3- 2>&4-

function list_all_of() {
	local TYPE=$1

	git log --oneline --tags --decorate --author-date-order | \
		grep 'tag: '$TYPE'' | \
		sed -E 's/^([[:xdigit:]]{7} )(.*)(tag: '$TYPE'_v([0-9]\.)+[0-9])(.*)/\1 \3/' | \
		awk '{print $1" "$3}' | sed -e 's/ '$TYPE'_/ /'
}

TYPE=$1

if [ "X${1}" == "Xfpga" ] || [ "X${1}" == "Xfirmware" ]; then
	list_all_of $TYPE | head -n1 | awk '{print $2}'
else
	echo "Error: $(basename $0) expects one argument [firmware|fpga]" 1>&2
	exit 1
fi

