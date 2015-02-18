#! /bin/bash
# Updates the stash & update cross-match matrix.
# Downloads if needed, but tries not to
if [ $# -ne 2 ]; then
	echo -n "ERROR: $(basename $(readlink -f $0)) takes exactly "
	echo "2 arguments: <\"dev\">|<\"git\"> <\"firmware\">|<\"fpga\">" 1>&2
	exit 1
fi

pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/../local/envsetup.sh
popd >/dev/null

INCLUDE funcs

REQ_VERSION=$2
GIT_DIR=$3

case $1 in
dev|device)
	TYPE="dev"
	;;
git)
	TYPE="git"
	;;
fw|firmware)
	TOOL="fw"
	;;
fpga)
	TOOL="fpga"
	;;
?)
	echo -n "Error: $(basename $(readlink -f $0)) expects first argument to be" 1>&2
	echo "either <type> or <firmware/fpga>" 1>&2
	return 1
	;;
esac

case $2 in
dev|device)
	TYPE="dev"
	;;
git)
	TYPE="git"
	;;
fw|firmware)
	TOOL="firmware"
	;;
fpga)
	TOOL="fpga"
	;;
?)
	echo -n "Error: $(basename $(readlink -f $0)) expects second argument to be" 1>&2
	echo "either <type> or <firmware>/<fpga>" 1>&2
	return 1
	;;
esac

which qryver_${TYPE}.sh 1>/dev/null || (echo "Bad <type> argument: \"${@}\"" 1>&2; exit 1)
qryver_${TYPE}.sh ${TOOL}
exit $?

