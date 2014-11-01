if [ "X${git_list_all_versionsof_sh}" != "Xy" ]; then
	git_list_all_versionsof_sh='y'

INCLUDE funcs/git_checkdir.sh

# Returns a list of SHA-1 and version for either firmaware or fpga
# Arguments:
# 1) required: String "firmware" or "fpga"
# 2) optional: Path to git (anywhere in tree). Default is $PWD

function git_list_all_versionsof() {
	local TYPE=$1
	local DIR="$2"
	local DIR=${DIR-$(pwd)}

	git_checkdir "$DIR"

	pushd "$DIR" >/dev/null

	git log --oneline --tags --decorate --author-date-order | \
		grep 'tag: '$TYPE'' | \
		sed -E 's/^([[:xdigit:]]{7} )(.*)(tag: '$TYPE'_v([0-9]\.)+[0-9])(.*)/\1 \3/' | \
		awk '{print $1" "$3}' | sed -e 's/ '$TYPE'_/ /'

	popd >/dev/null
}

fi
