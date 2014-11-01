if [ "X${git_getsha1_sh}" != "Xy" ]; then
	git_getsha1_sh='y'

INCLUDE funcs/git_checkdir.sh

# Returns shortform SHA-1 for current checkout
# Arguments:
# 1) optional: Path to git (anywhere in tree). Default is $PWD

function git_getsha1() {
	local DIR="$1"

	local DIR=${DIR-$(pwd)}
	git_checkdir "$DIR"

	pushd "$DIR" >/dev/null
	git log --oneline | head -n1 | awk '{print $1}'
	popd >/dev/null
}

fi
