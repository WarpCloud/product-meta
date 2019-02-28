#!/usr/bin/env bash
FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT="$(cd $(dirname $FILEPATH) && pwd)"
export PLATFORM_WALM_SERVICE_ADDRESS=http://172.16.3.234:31606
RESOUCE=$PROJROOT/../component_templates
URL=http://172.16.3.234:31606
REPO=stable

python3 $PROJROOT/config_generator.py $RESOUCE $URL $REPO