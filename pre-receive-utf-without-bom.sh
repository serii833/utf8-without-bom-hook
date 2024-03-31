#!/bin/bash

hasBOM() { 
  git cat-file -p $1 | head -c3 | grep -q $'\xef\xbb\xbf'
  local exitCode=$?
  if [[ "$exitCode" == "0" ]]; then
    return 1
  else
    return 0
  fi
}



err=0

while read -r oldrev newrev refname; do
  # echo ""
  # echo "-------------------------------------------------"
  # echo "oldrev $oldrev"
  # echo "newrev $newrev"
  # echo "refname $refname"
  # echo "-------------------------------------------------"
  # echo ""


  range="$oldrev..$newrev"

  # echo "range=$range"
  # echo ""

  for commit in $(git rev-list "$range" --not --all); do
    # printf "\n------\n"
    # echo "commit: $commit"
    # echo ""
    # git diff-tree --no-commit-id -r --abbrev $commit
    # echo ""

    for blobId in $(git diff-tree --no-commit-id -r --abbrev $commit | awk '{print $4}'); do
      hasBOM "$blobId"
      bom=$?

      if [[ "$bom" == "1" ]]; then
        printf "=== has BOM ===\n"
        printf "commit: $commit"
        echo $(git ls-tree -r $commit | grep $blobId)
        err=1
      fi
    done
  done
done


exit $err
