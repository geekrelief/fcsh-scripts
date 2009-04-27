#!/bin/bash
#creates a named pipe. reads from it. sends to fcsh. parses output of fcsh.

#get resources.
if [[ "$FCSH_VIM_ROOT" = "" ]]; then
    FCSH_VIM_ROOT="$HOME/bin"
fi
source "$FCSH_VIM_ROOT/fcshrc.sh"
prog="fcsh"

# create lock directory
if mkdir "$lockdir"; then
    echo "$lockdir created"
else
    echo >&2 "$lockdir found. Can't continue."
    echo >&2 "killall fcsh && rm -rf $lockdir"
    exit 1
fi

#initialization
mkfifo "$pipein"
trap "rm -rf $lockdir" 0
trap "exit 2" 2 9 15

function process_fcsh_output {
#processes output of fcsh
while read line; do
    echo "$line"
    if [[ "$line" == *Error* ]]; then
        echo >&2 "[INFO] compilation error."
        echo "$cmpbad" > "$cmpdone"
    elif [[ "$line" == Recompile* ]]; then
        echo >&2 "[INFO] incremental compilation attempt without initial compilation."
        echo "$cmpre" > "$cmpdone"
    elif [[ "$line" == *.swf\ \(* ]]; then
        echo >&2 "[INFO] compilation finished."
        echo  "$cmpnice" > "$cmpdone"
    elif [[ "$line" == *Assigned* ]]; then
        echo >&2 "[INFO] possible id assignment."
        line="${line##*Assigned }"
        line="${line%% *}"
        if [[ "$line" == [0-9]* ]]; then
            echo >&2 "[INFO] id assigned: $line"
            echo "$line" > "$idcurr"
        fi
    elif [[ "$line" == \(fcsh\)* ]]; then
        echo >&2 "[INFO] fcsh prompt."
        rm -rf "$cmpdone"
        echo >&2 "[INFO] $cmpdone removed"
    fi
done
}

function send_to_fcsh {
#reads from $pipein and sends it to fcsh
#also, writes output of fcsh to $pipeout
while sleep 1; do
    read line < "$pipein"
    echo "$line"
done | "$prog" 2>&1 | process_fcsh_output
}

#main
echo >&2 "[INFO] starting server."
send_to_fcsh

