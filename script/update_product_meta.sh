#!/usr/bin/env bash
# Testing module for product-meta

set -e

FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT="$(cd $(dirname $FILEPATH) && pwd)/.."
INSTANCEW_PATH="$PROJROOT/instances"

# TODO: add the param for update
ORIGIN_VERSION="tdc-1.2/transwarp-6.0/sophonweb-2.0"
UPDATE_RELEASE="tdc-1.2"
UPDATE_VERSION="tdc-1.2.0-rc0/transwarp-6.0.0-final/sophonweb-2.0.0-rc4"
IS_FINAL="true"
EXCLUDE="sophon/ogg/ogg-for-big-data"

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
python3 $PROJROOT/script/deploy_version.py $INSTANCEW_PATH $ORIGIN_VERSION $UPDATE_VERSION $IS_FINAL $EXCLUDE $UPDATE_RELEASE


#  Usage:
#  1. update instance must have root version
#  eg.  update version to tdc-1.2.0-rc1, image.yaml must have tdc-1.2

#  2. update all instance version to final or rc
#     ORIGIN_VERSION="tdc-1.1/transwarp-5.2/sophonweb-1.2"
#     UPDATE_RELEASE="tdc-1.1/transwarp-5.2/sophonweb-1.2"
#     UPDATE_VERSION="tdc-1.1.0-rc3/transwarp-5.2.1-final/sophonweb-1.3.0-final"
#
#     or don't add $UPDATE_RELEASE
#     python3 $PROJROOT/script/deploy_version.py $INSTANCEW_PATH $ORIGIN_VERSION $UPDATE_VERSION $IS_FINAL $EXCLUDE

#  3. only update one version, and use old version
#  eg. update tdc-1.1.0-final and don't update transwarp-5.2.1-final/sophonweb-1.3.0-final
#     ORIGIN_VERSION="tdc-1.1/transwarp-5.2/sophonweb-1.2"
#     UPDATE_RELEASE="tdc-1.1"
#     UPDATE_VERSION="tdc-1.1.0-final/transwarp-5.2.1-final/sophonweb-1.3.0-final"
#
#     and used
#     python3 $PROJROOT/script/deploy_version.py $INSTANCEW_PATH $ORIGIN_VERSION $UPDATE_VERSION $IS_FINAL $EXCLUDE $UPDATE_RELEASE


# Tips:
# change dependency instance range:
# python3 $PROJROOT/script/change_range_for_dependency.py $INSTANCEW_PATH transwarp-5.2.2-final tdc-1.1.0-rc4 tdc-1.1.0-rc4/tdc-1.1.0-rc0
#python3 $PROJROOT/script/change_range_for_dependency.py $INSTANCEW_PATH tdc-1.1.0-final transwarp-5.2.2-final transwarp-5.2.2-final/transwarp-5.2.1-final
