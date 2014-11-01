# Environment settings common to all scripts in this package.
# To be sourced from scripts in this package only.

if [ "X${BRF_ENV_SET}"="Xy" ]; then
# No need to do any this if it's already done
	export BRF_ENV_SET='y'
	export BRF_DIR=$(dirname $(readlink -f $0))
	
	DFLT_BRF_VERBOSE="no"
	DFLT_BRF_SERVER="https://www.nuand.com"
	DFLT_BRF_FPGADIR="fpga"
	DFLT_BRF_FX3DIR="fx3"
	DFLT_BRF_STASH_DIR="~/.bladerf_transbin"
	
	BRF_DOTFILE=.bladerf
	if ! [ -f "${HOME}/${BRF_DOTFILE}" ]; then
		if [ "X${BRF_VERBOSE}" == "Xyes" ]; then
			echo "WARN: ${BRF_DOTFILE} not setup - Creating a default." 1>&2
		fi
		touch ${BRF_DOTFILE}
		echo "DFLT_BRF_VERBOSE=${DFLT_BRF_VERBOSE}"
		echo "DFLT_BRF_SERVER=${DFLT_BRF_SERVER}"
		echo "DFLT_BRF_FPGADIR=${DFLT_BRF_FPGADIR}"
		echo "DFLT_BRF_FX3DIR=${DFLT_BRF_FX3DIR}"
		echo "DFLT_BRF_STASH_DIR=${DFLT_BRF_STASH_DIR}"
	fi
	# Get user settings and set if not set
	# Parse one line at a time (i.e. each setting in config in config is a
	# fall-back and can be overloaded)
	for L in $(
		cat "${HOME}/${BRF_DOTFILE}" | \
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

fi
