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
	unset LOADFILE;
}

function check_match()
{
	MATCH="$1";
	for MATCHDATA in ${FINALDATA_ARR[*]};
	do
		if grep -q $MATCH <<< "$MATCHDATA"; then
			MATCHTRIGGER='0';
			break;
		else
			MATCHTRIGGER='1';
		fi;
	done;
	
	if [[ $MATCHTRIGGER -eq 0 ]]; then
		echo "File exists: $MATCH";
		RETVAL=0;
	else
		echo "File not found: $MATCH";
		RETVAL=1;
	fi;
	unset MATCH MATCHTRIGGER;
	return $RETVAL;
}

FILE='/var/tmp/data_db.out';
sqlite3 "/Library/Application Support/Apple/AssetCache/Data/AssetInfo.db" 'select * from ZASSET;' > "$FILE";
load_db "$FILE";
SEARCH_ARR=('1365d156a39f2873c6286ea051c6d51a4a1aeaa0.zip' '5cf792207827e2b80c7f04d8f70b2efb291eadf6.zip' '36ca6bf5da9432edecce30f8cbab94b9bc16d25b.zip' 'eb687e0b15f4de25efccd8eac72515f111844230.zip');

for SEARCHMODE in ${SEARCH_ARR[*]};
do
	if check_match $SEARCHMODE;
		BOOLVAR='0';
	fi;
done;

if [[ $BOOLVAR -eq 0 ]]; then
	echo "File(s) found." > /var/tmp/result.out;
else
	echo "File(s) not found or missing" > /var/tmp/result.out;
fi;

# Cleanup Mode
if [ -f "$FILE" ]; then
	rm -rf "$FILE";
fi;
unset SEARCH_ARR FINALDATA_ARR RETVAL FILE;
