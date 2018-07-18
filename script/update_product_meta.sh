#!/usr/bin/env bash
# Testing module for product-meta

set -e

FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT="$(cd $(dirname $FILEPATH) && pwd)/.."
INSTANCEW_PATH="$PROJROOT/instances"

# TODO: add the param for update
ORIGIN_VERSION="tdc-1.1/transwarp-5.2/sophonweb-1.2"
UPDATE_VERSION="tdc-1.1.0-rc0/transwarp-5.2.1-rc0/sophonweb-1.3.0-rc0"
IS_FINAL="true"
EXCLUDE="sophon"

# Validate images in instances
pip3 install -r $PROJROOT/script/script-requirements.txt \
	-U -i http://172.16.1.161:30033/repository/pypi/simple/ \
	--trusted-host=172.16.1.161
chmod +x $PROJROOT/script/deploy_version.py

echo $INSTANCEW_PATH
echo $ORIGIN_VERSION
echo $UPDATE_VERSION
echo $IS_FINAL
echo $EXCLUDE
python3 $PROJROOT/script/deploy_version.py $INSTANCEW_PATH $ORIGIN_VERSION $UPDATE_VERSION $IS_FINAL $EXCLUDE
