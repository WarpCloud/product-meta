#!/usr/bin/env bash
# Testing module for product-meta

set -e

FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT=$(cd $(dirname $FILEPATH) && pwd)
export PROJROOT=$PROJROOT

# Validate products/componets/applications/resources
chmod +x $PROJROOT/tests/validate_products.sh
$PROJROOT/tests/validate_products.sh

# Validate images in instances
pip3 install -r $PROJROOT/requirements-testing.txt\
	-U -i http://172.16.1.161:30033/repository/pypi/simple/ \
	--trusted-host=172.16.1.161

python3 $PROJROOT/tests/validate_instance_images.py
# python3 $PROJROOT/tests/validate_component_value.py
python3 $PROJROOT/tests/validate_value.py
python3 $PROJROOT/tests/validate_etc.py
