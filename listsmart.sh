#!/bin/bash
# Author : jonakrob
# License: GPL3, http://www.gnu.org/copyleft/gpl.html
# Credit : Mark Wu, http://blog.markplace.net

# Stop Verbose lines, thanks to Mark Harrison
TODOTXT_VERBOSE=0

if [ -z "$TODOTXT_DIST" ]; then
	TODOTXT_DIST=1
fi

# Get action
action=$1
shift

# Get option
option=$1;
shift

# Get rest of them
#term="$@"
term=$option


function usage() {
    echo "  $(basename $0) [TERM]"
    echo ""
    exit
}

# Levenshtein distance
levdistval=0
function levdist() {
	s=$1
	t=$2
	if [ "$s" == "$t" ]; then
		levdistval=0
		return
	fi
	if [ -z "$s" ]; then
		levdistval=${#t}
		return
	fi
	if [ -z "$t" ]; then
		levdistval=${#s}
		return
	fi
	for (( i=0; i<${#t}+1; i++ )); do
		v0[$i]=$i
		#echo ${v0[i]}
	done
	for (( i=0; i<${#s}; i++ )); do
		v1[0]=$((i+1))
		#echo v1[0]=${v1[0]}
		for (( j=0; j<${#t}; j++ )); do
			if [ ${s:i:1} == ${t:j:1} ]; then
				cost=0
			else
				cost=1
			fi
			#echo cost=$cost
			minimum=$((v1[j]+1))
			#echo $minimum
			if [ $((v0[j+1]+1)) -le $minimum ]; then minimum=$((v0[j+1]+1)); fi
			#echo $minimum
			if [ $((v0[j]+cost)) -le $minimum ]; then minimum=$((v0[j]+cost)); fi
			#echo $minimum
			v1[$((j+1))]=$minimum
		done
		for (( j=0; j<${#t}+1; j++ )); do
			v0[$j]=${v1[j]}
		done
	done
	levdistval=${v1[${#t}]}
	#echo $s $t
	#echo levdistval=$levdistval
}

# Basic distance
distval=0
function dist() {
	foo=$1
	bar=$2
	if [[ ${#foo} < ${#bar} ]] ; then tmp=$foo; foo=$bar; bar=$tmp; fi
	d=0
	for (( i=0; i<${#foo}; i++ )); do
		if [[ ${foo:$i:1} != ${bar:$i:1} ]] ; then d=$((d+1)) ; fi
	done
	distval=$d
}

FILE=$TODO_FILE
items=$(
        if [ "$FILE" ]; then
            sed = "$FILE"
        else
            sed =
        fi                                                      \
        | sed -e '''
            N
            s/^/     /
            s/ *\([ 0-9]\{'"$PADDING"',\}\)\n/\1 /
            /^[ 0-9]\{1,\} *$/d
         '''
    )
TOTALTASKS=$( echo -n "$items" | sed -n '$ =' )

PROJECTS=$(grep -o '[^  ]*+[^  ]\+' "$TODO_FILE" | grep '^+' | sort -u | sed 's/^+//g')
CONTEXTS=$(grep -o '[^  ]*@[^  ]\+' "$TODO_FILE" | grep '^@' | sort -u | sed 's/@//g')

shown=0
if [[ ${option:0:1} == '+' ]] ; then
	for project in $PROJECTS; do
		levdist "+${project}" $term
		#echo project=$project
		#echo levdistval=$levdistval
		if [ $levdistval -le $TODOTXT_DIST ] ; then term=$project ; fi
		#echo term=$term
	done
	for project in $PROJECTS; do
    	PROJECT_LIST=$(_list "$TODO_FILE" "+$project\b" "$term" | sed 's/\(^+\|\ *+\)[a-zA-Z0-9\{._\-\}]*\ */ /g')
    	#echo $project
    	#echo ${#PROJECT_LIST}
    	#echo "${PROJECT_LIST:0:$((${#PROJECT_LIST}-2))}"
    	if [ -z "$PROJECT_LIST" ]; then continue; fi
		shown=$( echo "$PROJECT_LIST" | wc -l )
    	echo "$PROJECT_LIST"
	done
	echo --
	#echo $( echo -n "$PROJECT_LIST" )
	echo TODO: $shown of $TOTALTASKS tasks shown
fi
if [[ ${option:0:1} == '@' ]] ; then
	for context in $CONTEXTS; do
		levdist "@${context}" $term
		if [ $levdistval -le $TODOTXT_DIST ] ; then term=$context ; fi
	done
	for context in $CONTEXTS; do
		CONTEXT_LIST=$(_list "$TODO_FILE" "@$context\b" "$term" | sed 's/(^@|\ *@)[^[:cntrl:] ]\ */ /g')
		if [ -z "$CONTEXT_LIST" ]; then continue; fi
		shown=$( echo "$CONTEXT_LIST" | wc -l )
		echo "${CONTEXT_LIST}"
	done
	echo --
	echo TODO: $shown of $TOTALTASKS tasks shown
fi

