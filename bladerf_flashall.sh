#! /bin/bash

DOTFILE=.bladerf
# Get user settings
eval $(
	cat "${HOME}/${DOTFILE}" | \
	grep -vE '^#' | \
	grep -vE '^[[:space:]]*$' | \
	sed -E 's/^/export /'
)

if [ "X${TRANSBIN_DIR}" == "X" ]; then
	echo "BAT config error" 1>&2
	echo "Did you configure a [~/$(DOTFILE)]?" 1>&2
	exit 1
fi

set -o pipefail

exec 3>&1 4>&2 1>/dev/null 2>/dev/null
if ! git remote -v | grep bladeRF.git | wc -l; then
	exec 1>&3- 2>&4-
	echo "You don't seem to be executing somewhere from withing BladeRF src-dir" 1>&2
	exit 1
fi
exec 1>&3- 2>&4-

git log --oneline --tags --decorate --author-date-order | \
	grep "tag: fpga_" | \
	head -n1 | \
	cut -f2 -d":" | \
	cut -f1 -d")" | \
	cut -f2 -d"_"

