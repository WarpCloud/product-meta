#!/usr/bin/env bash
# Testing module for product-meta
set -e

FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT=$(cd $(dirname $FILEPATH) && pwd)
export PROJROOT=$PROJROOT

# Validate products/componets/applications/resources
chmod +x $PROJROOT/tests/validate_products.sh
$PROJROOT/tests/validate_products.sh

python3 $PROJROOT/tests/validate_instance_images.py
# python3 $PROJROOT/tests/validate_component_value.py
python3 $PROJROOT/tests/validate_value.py
python3 $PROJROOT/tests/validate_etc.py
