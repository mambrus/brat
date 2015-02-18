#! /bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/../local/envsetup.sh
popd >/dev/null

INCLUDE funcs

$@
