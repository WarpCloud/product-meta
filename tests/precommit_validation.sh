#!/bin/bash
# Verminator validation
FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT=$(cd $(dirname $FILEPATH)/.. && pwd)
export PROJROOT=$PROJROOT

verminator validate $PROJROOT/instances
CHANGED=`git status -s | wc -l`
if [[ $CHANGED -gt 0 ]]; then
echo "------ Git status ------"
git status -s
echo "------ Git diff ------"
git diff > /tmp/ver_validation.diff
cat /tmp/ver_validation.diff
echo "Multiple files failed verminator validation!"
echo "Please run: verminator validate /path/to/product-meta/instances"
else
echo "SUCCESS"
fi