#!/usr/bin/env bash
FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT="$(cd $(dirname $FILEPATH) && pwd)"
RESOUCE=$PROJROOT/resouce_config
URL=http://172.16.3.231:32360

python3 $PROJROOT/register_config_center.py $RESOUCE $URL