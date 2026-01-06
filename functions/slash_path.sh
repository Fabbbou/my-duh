#!/usr/bin/env bash

# Convert a given path to a slash path
# Usage: slash_path "C:\Users\Name\path\to\file.txt"
# Output: "/c/Users/Name/path/to/file.txt"
slash_path(){
    local input_path="$1"
    local slash_path="${input_path//\\//}"
    
    # Convert Windows drive paths to Unix-style paths
    if [[ $slash_path =~ ^[A-Za-z]:/ ]]; then
        local drive_letter="${slash_path:0:1}"
        local rest_of_path="${slash_path:2}"
        slash_path="/${drive_letter,,}${rest_of_path}"
    fi
    
    echo "$slash_path"
}