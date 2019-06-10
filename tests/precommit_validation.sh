#!/bin/bash
# Verminator validation
FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT=$(cd $(dirname $FILEPATH)/.. && pwd)
export PROJROOT=$PROJROOT

wget --header "PRIVATE-TOKEN: _CzK6kpWi2jkyT4BjBZ-" \
"http://172.16.1.41:10080/api/v4/projects/InfraTools%2Ftranswarp-continuous-delivery/repository/files/script%2Fcommon%2Fmetainfo%2FTDC%2Ftdc-2.0%2Freleases%2Freleases_meta.yaml/raw?ref=master" \
-O "/tmp/releases_meta.yaml"
verminator validate --releasemeta /tmp/releases_meta.yaml $PROJROOT/instances

CHANGED=`git status -s | wc -l`
if [[ $CHANGED -gt 0 ]]; then
  echo "------ Git status ------"
  git status -s
  echo "------ Git diff ------"
  git diff > /tmp/ver_validation.diff
  cat /tmp/ver_validation.diff
  echo "Multiple files failed verminator validation!"
  echo "Please run: verminator validate /path/to/product-meta/instances"
  exit 1
else
  echo "SUCCESS"
  exit 0
fi