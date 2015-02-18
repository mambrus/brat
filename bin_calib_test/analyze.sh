#!/bin/bash

if [ $# -gt 0 ]; then
	CAT="cat $1"
else
	CAT="cat --"
fi

$CAT | sed 's/[[:cntrl:]]/\n/g' | awk '
	function print_calib_tab_stats( N, TIME, TYPE, C, RES) {
		printf("%3d %9d %s %4d %4s\n",N,TIME,TYPE,C,RES);
	}

	/* If in ANY mode, print stats for that mode and reset it */
	function print_laststat_ifneeded() {
		/* No mode should be pending. If so its a fail. */
		/* Print stat and reset counters */
		if (TB_TX_MODE) {
			TB_TX_MODE_FAIL++;
			print_calib_tab_stats(NR_TEST,CURR_TIME,"TX",N_CAL_TX,"FAIL");
			N_CAL_TX=0;
			TB_TX_MODE=0;
		}
		if (TB_RX_MODE) {
			TB_RX_MODE_FAIL++;
			print_calib_tab_stats(NR_TEST,CURR_TIME,"RX",N_CAL_RX,"FAIL");
			N_CAL_RX=0;
			TB_RX_MODE=0;
		}
	}

	BEGIN {
		TB_TX_MODE=0;
		TB_RX_MODE=0;
		TB_TX_MODE_SUCCESS=0;
		TB_RX_MODE_SUCCESS=0;
		TB_TX_MODE_FAIL=0;
		TB_RX_MODE_FAIL=0;
		CURR_TIME=0;
	}

	/* -- */
	/* Time marker AND iteration start marker */
	/* -- */
	/^[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]/ {
		#print "hepp: "$0
		print_laststat_ifneeded();
		NR_TEST++;
		time="date -d\""$0"\" +%s"
		time | getline CURR_TIME
		close(time)
		#print CURR_TIME
	}
	/* -- */
	/* Time marker */
	/* -- */
	/^>>>TIMESTAMP: [0-9][0-9]\/[0-9][0-9]\/[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]/ {
		#print "hopp: "$0
		print_laststat_ifneeded();
		gsub(">>>TIMESTAMP: ","");
		time="date -d\""$0"\" +%s"
		time | getline CURR_TIME
		close(time)
		#print CURR_TIME
	}
	/[[:space:]]+Done\./ {
		if (TB_TX_MODE) {
			TB_TX_MODE_SUCCESS++;
			print_calib_tab_stats(NR_TEST,CURR_TIME,"TX",N_CAL_TX,"OK");
		}
		if (TB_RX_MODE) {
			TB_RX_MODE_SUCCESS++;
			print_calib_tab_stats(NR_TEST,CURR_TIME,"RX",N_CAL_RX,"OK");
		}
		TB_RX_MODE=0;
		TB_TX_MODE=0;
		N_CAL_TX=0;
		N_CAL_RX=0;
	}
	/* Count number of calibration entries for current table */
	/Calibrating \@ [0-9]+ Hz.*\)$/{
		if (TB_TX_MODE) {
			N_CAL_TX++;
		}
		if (TB_RX_MODE) {
			N_CAL_RX++;
		}
	}
	/* A new cal table (RX) has started */
	/cal table dc rx/{
		print_laststat_ifneeded();
		TB_TX_MODE=0;
		TB_RX_MODE=1;
		NTB_RX_MODE++;
	}
	/* A new cal table (TX) has started */
	/cal table dc tx/{
		print_laststat_ifneeded();
		TB_RX_MODE=0;
		TB_TX_MODE=1;
		NTB_TX_MODE++;
	}
	END{
		print "========================"
		print "TX tables: "NTB_TX_MODE"/"TB_TX_MODE_SUCCESS"/"TB_TX_MODE_FAIL
		print "RX tables: "NTB_RX_MODE"/"TB_RX_MODE_SUCCESS"/"TB_RX_MODE_FAIL
	}'
