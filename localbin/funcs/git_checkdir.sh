if [ "X${git_checkdir_sh}" != "Xy" ]; then
	git_checkdir_sh='y'

# Checks in you're in a valid git
# Arguments:
# 1) optional: Path to git (anywhere in tree). Default is $PWD

function git_checkdir() {
	local DIR="$1"
	local DIR=${DIR-$(pwd)}

	pushd "$DIR" >/dev/null

	HAD_PIPEFAIL=$(set | grep -E '^SHELLOPTS' | grep pipefail)
	set -o pipefail
	exec 3>&1 4>&2 1>/dev/null 2>/dev/null
	if ! git remote -v | grep bladeRF.git | wc -l; then
		exec 1>&3- 2>&4-
		echo "FATAL: You don't seem to be executing in a valid git repo" 1>&2
		exit 1
	fi
	exec 1>&3- 2>&4-
	if [ "no${HAD_PIPEFAIL}" == "no" ]; then
		set +o pipefail
	fi

	popd >/dev/null
}

fi
