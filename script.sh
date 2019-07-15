#!/bin/bash

function load_db()
{
	LOADFILE="$1";
	DATA_ARR=();
	FINALDATA_ARR=();
	while IFS= read -r line;
	do
		DATAVAR=$(echo "$line" | awk -F '|' '{print $13}' | tr "/" "\n");
		for DATA in $DATAVAR;
		do
			DATA_ARR+=($(echo $DATA));
		done;
		FINALDATA_ARR+=($(echo ${DATA_ARR[-1]}));
		unset DATA_ARR DATAVAR;
	done < $LOADFILE;
}

function check_match()
{
	MATCH="$1";
	for MATCHDATA in ${FINALDATA_ARR[*]};
	do
		if grep -q $MATCH <<< "$MATCHDATA"; then
			MATCHTRIGGER='1';
			break;
		else
			MATCHTRIGGER='0';
		fi;	
	done;

	if [[ $MATCHTRIGGER -eq 1 ]]; then
		echo "File exists: $MATCH";
	else
		echo "File not found: $MATCH";
	fi;
	unset MATCH MATCHTRIGGER;
}

FILE='/home/joseph/data.txt';

load_db $FILE;
cat $FILE;
echo "";
check_match "1365d156a39f2873c6286ea051c6d51a4a1aeaa0.zip";
check_match "hajheqjhq.zip";


