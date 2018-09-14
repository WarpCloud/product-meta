#!/usr/bin/env bash
set -e

FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
export PROJROOT="$(cd $(dirname $FILEPATH) && pwd)/.."
COMPONENT_PATH="$PROJROOT/components"
SCRIPT=$PROJROOT/script/set_component_description.py
chmod +x $SCRIPT

echo "From version: $1"
echo "Upgrade to version: $2"

for component_type in $COMPONENT_PATH/*; do
    for version in $component_type/*; do
        if [ ${version##*/} == $1 ]; then
            if [ ! -d $component_type/$2 ]; then
                mkdir $component_type/$2
                cp -r $version/* $component_type/$2
            fi
            python3 $SCRIPT -c ${component_type##*/} -v $2
        fi
    done
done
