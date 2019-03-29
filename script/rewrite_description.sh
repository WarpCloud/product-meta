#!/usr/bin/env bash
set -e

FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
export PROJROOT="$(cd $(dirname $FILEPATH) && pwd)/.."
COMPONENT_PATH="$PROJROOT/components"
SCRIPT=$PROJROOT/script/rewrite_description.py
chmod +x $SCRIPT

function usage() {
    echo "usage:"
    echo "component|product|"
    echo "Commands"
    echo -e "\t component validate [type src-version target-version]\tvalidate component-version description"
    echo -e "\t product rm-useless\tremove useless description from products"
    exit 1
}

function validate_component() {
    echo "From version: $1"
    echo "Upgrade to version: $2"
    echo "Choose component: $3"

    for component_type in $COMPONENT_PATH/*; do
        if [ $3 != '' ];then
            if [ ${component_type##*/} == $3 ];then
                echo "find $3"
            else
                continue
            fi
        fi
        for version in $component_type/*; do
            if [ ${version##*/} == $1 ]; then
                if [ ! -d $component_type/$2 ]; then
                    mkdir $component_type/$2
                    cp -r $version/* $component_type/$2
                fi
                python3 $SCRIPT component validate -c ${component_type##*/} -v $2
            fi
        done
    done
}

if [ $1 == component ]; then
    if [ $2 == validate  ]; then
        shift 2
        validate_component $2 $3 $1
    fi
elif [ $1 == rm-useless ]; then
    python3 $SCRIPT all rm-useless
else
    usage
fi
