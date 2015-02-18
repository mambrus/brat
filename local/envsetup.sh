# Environment settings common to all scripts in this package.
# To be sourced from scripts in this package only.

if [ "X${BRF_ENV_SET}" != "Xy" ]; then
# No need to do any this if it's already done
	export BRF_ENV_SET='y'
	export BRF_DIR=$(dirname $(readlink -f $0))

	DFLT_BRF_VERBOSE="no"
	DFLT_BRF_SERVER="https://www.nuand.com"
	DFLT_BRF_FPGADIR="fpga"
	DFLT_BRF_FX3DIR="fx3"
	DFLT_BRF_STASH_DIR="${HOME}/.bladerf_transbin"

	BRF_DOTFILE="${HOME}/.bladerf"
	if [ ! -f "${BRF_DOTFILE}" ]; then
		if [ "X${BRF_VERBOSE}" == "Xyes" ]; then
			echo "WARN: ${BRF_DOTFILE} not setup - Creating a default." 1>&2
		fi
		touch ${BRF_DOTFILE}
		echo "BRF_VERBOSE=${DFLT_BRF_VERBOSE}"      >> ${BRF_DOTFILE}
		echo "BRF_SERVER=${DFLT_BRF_SERVER}"        >> ${BRF_DOTFILE}
		echo "BRF_FPGADIR=${DFLT_BRF_FPGADIR}"      >> ${BRF_DOTFILE}
		echo "BRF_FX3DIR=${DFLT_BRF_FX3DIR}"        >> ${BRF_DOTFILE}
		echo "BRF_STASH_DIR=${DFLT_BRF_STASH_DIR}"  >> ${BRF_DOTFILE}
	fi
	# Get user settings and set if not set
	# Parse one line at a time (i.e. each setting in config in config is a
	# fall-back and can be overloaded)
	for L in $(
		cat "${BRF_DOTFILE}" | \
		grep -vE '^#' | \
		grep -vE '^[[:space:]]*$'
	); do
		E=$(echo $L | cut -d"=" -f1)
		V=$(eval echo \$$E)
		if [ "X$V" == "X" ]; then
			#echo "Setting value for envvar $E"
			eval $(echo "export $L")
		fi
	done

	#General settings (further fall-backs)
	export BRF_VERBOSE=${BRF_VERBOSE-${DFLT_BRF_VERBOSE}}
	export BRF_SERVER=${BRF_SERVER-${DFLT_BRF_SERVER}}
	export BRF_FPGADIR=${BRF_FPGADIR-${DFLT_BRF_FPGADIR}}
	export BRF_FX3DIR=${BRF_FX3DIR-${DFLT_BRF_FX3DIR}}
	export BRF_STASH_DIR=${BRF_STASH_DIR-${DFLT_BRF_STASH_DIR}}

	export PATH=$(pwd):$PATH

	#source ${BRF_DIR}/.env_common

	# Source either specific functions or directories from local
	function INCLUDE() {
		if [ "X${1}" == "X" ]; then
			echo "FATAL: $0 expects one argument" 1>&2
			exit 1
		fi
		local DNAME="${BRF_DIR}"
		local FNAME="${DNAME}/../${1}"

		if [ -d "${FNAME}" ]; then
			for F in $(ls ${FNAME}); do
				local F="${FNAME}/${F}"
				source "${F}"
			done
		else
			source "${FNAME}"
		fi
	}
	typeset -fx INCLUDE

fi
