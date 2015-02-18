#! /bin/bash

# This script pulls out the Serial IDentity in the format required for
# bladeRF-cli -p flag.

# To identify a bladeRF device for -p is a nuance as bus and address keeps
# changing on each attachment. As the serial number is probably unique
# enough, all you need is this number in buffer or given in scripts and
# you're good to go.

# Use like this:

# bladeRF-cli -p $(brat sid <#serial>) ...

if [ $# -ne 1 ]; then
	echo "ERROR: $(basename $(readlink -f $0)) takes/need one argument only (SERIAL)" 1>&2
	exit 1
fi

bladeRF-cli -p | \
	grep $1 -B1 -A2 | \
	awk '
		NR==1{BACKEND=$2}
		NR==2{SERIAL=$2}
		NR==3{UBUS=$3}
		NR==4{UADDR=$3}
		END{
			print BACKEND":device="UBUS":"UADDR" serial="SERIAL
		}'
