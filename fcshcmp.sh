#!/bin/bash
#talks to fcshserv to compile a mxml/as file.
#first parameter should be full path to the file name to be compiled.
#second parameter is optional. if it is present, flashplayer will launch.

#check usage error.
if (( $# < 1 )); then
    echo >2& "I need a file name!"
    exit 1
fi

#get resource.
if [[ "$FCSH_VIM_ROOT" = "" ]]; then
    FCSH_VIM_ROOT="$HOME/bin"
fi
source "$FCSH_VIM_ROOT/fcshrc.sh"

#variables
file="$1"
swf="${file%.*}.swf"
flashplayer="flashplayer"

#check if $file is full path
if [[ ! "$file" == */* ]]; then
    echo >2& "$file has to be full path"
    exit 1
fi

#check if server is running.
if [[ ! -d "$lockdir" ]]; then
    echo >&2 "$lockdir does not exist. please execute $FCSH_VIM_ROOT/fcshstart.sh first"
    exit 1
fi

echo "------------------------BEGIN-------------------------------------"



#get $file's id from the server for next incremental compilation.
idfile="$lockdir/${file//\//_}"
echo "idfile: $idfile"

#send message to fcsh
if [[ -f "$idfile" ]]; then
    echo "incremental compilation"
    id=$( head -1 "$idfile" )
    echo "compile $id" > "$pipein"
else
    echo "initial compilation"
    echo "mxmlc -verbose-stacktraces -debug --strict $file" > "$pipein"
fi

#wait until fcsh finishes current compilation.
until [[ -f "$cmpdone" ]]; do
    echo -n "."
    sleep 1
done
echo ""

cmpmessage=$( head -1 "$cmpdone" )
rm -rf "$cmpdone"
echo  "compilation status: $cmpmessage"

if [[ "$cmpmessage" == "$cmpnice" ]]; then

    #it was initial compilation. store id.
    if [[ -f "$idcurr" ]]; then
        id=$( head -1 "$idcurr" )
        rm -rf "$idcurr"
        echo "id: $id"
        echo "$id" > "$idfile"
    fi

    #user wants to run flashplayer
    if (( $# >= 2 )); then
        echo "launching flashplayer."
        "$flashplayer" "$swf" &
    fi
else
    #compilation was not successful.
    rm -rf "$idfile"
    rm -rf "$idcurr"
    echo "please recompile."
fi

echo "=============================END================================="
