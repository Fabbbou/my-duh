#!/usr/bin/env bash

# Transforms a slash-separated string into a formatted output where:
#   - Every path segment except the last is wrapped in square brackets []
#   - The last segment has dashes (-) replaced with spaces
#   - The last segment is not wrapped in brackets
# Example:
#   Input:
#     it/is/a/string/with-multiple/slashes-inside-the-stuff
#   Output:
#     [it][is][a][string][with-multiple] slashes inside the stuff
# Usage:
#   ./branch_to_pr_title.sh "your/slash-separated/string"
branch_to_pr_title(){
    
  input="$1"

  if [ -z "$input"  ]; then
    echo " Usage:"
    echo "    ./branch_to_pr_title.sh 'your/slash-separated/string'"
    echo 'out: [it][is][a][string][with-multiple] slashes inside the stuff'
    return 1
  fi


  # Extract last segment
  last=${input##*/}

  # Replace - with space in last segment
  last=$(echo "$last" | tr '-' ' ')

  # Extract everything before last slash
  prefix=${input%/*}

  # Wrap each prefix segment in []
  if [ "$prefix" != "$input" ]; then
      oldIFS=$IFS
      IFS='/'
      for part in $prefix; do
          printf '[%s]' "$part"
      done
      IFS=$oldIFS
  fi

  # Print last segment
  printf ' %s\n' "$last"
}
