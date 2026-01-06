#!/usr/bin/env bash

# Edit the file given in $1 if the EDITOR var is setup properly
# $EDITOR must point to a valid file/directory editor in order to work
#
# Usage: edit a_file.txt
edit(){
    require "$EDITOR" || return 1

    local path_to_open="$1"
    $EDITOR "$path_to_open"
}