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
pip3 install -r $PROJROOT/tests/py-requirements.txt \
	-U -i http://172.16.1.161:30033/repository/pypi/simple/ \
	--trusted-host=172.16.1.161
pip3 install -r $PROJROOT/requirements-testing.txt\
	-U -i http://172.16.1.161:30033/repository/pypi/simple/ \
	--trusted-host=172.16.1.161
python3 $PROJROOT/tests/validate_instance_images.py
# python3 $PROJROOT/tests/validate_component_value.py
python3 $PROJROOT/tests/validate_value.py
python3 $PROJROOT/tests/validate_etc.py

# Verminator validation
verminator validate $PROJROOT/instances
CHANGED=`git status -s | wc -l`
if [[ $CHANGED -ge 0 ]]; then
echo "------ Git status ------"
git status -s
echo "------ Git status ------"
echo "------ Git diff ------"
git diff > /tmp/ver_validation.diff
cat /tmp/ver_validation.diff
echo "Multiple files failed verminator validation!"
echo "Please run: verminator validate /path/to/product-meta/instances"
echo "------ Git diff ------"
else
echo "SUCCESS"
fi