#!/bin/bash
pushd $(dirname $(readlink -f $0))	>/dev/null
source $(pwd)/../local/envsetup.sh
popd >/dev/null

if [ $# -gt 0 ]; then
	CAT="cat $1"
else 
	CAT="cat --"
fi

$CAT | analyze.sh | awk '
	$3=="RX" || $3=="TX" {
		printf("%s",LL); 
		LL=$0; 
		if (TLAST==0){
			printf(" %d\n",TLAST);
		}else{
			printf(" %d\n",$2-TLAST);
		};TLAST=$2
	}
	END{
		printf("%s  ??",LL);
	}' | awk 'NR>1{print}'

