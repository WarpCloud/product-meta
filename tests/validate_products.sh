#!/usr/bin/env bash
# Testing module for product-meta

set -e

FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT="$(cd $(dirname $FILEPATH) && pwd)/.."
COMPONENTS="/components"
RESOURCES="/resources"
SYS_COMPONENTS="/components"
SYS_CONTEXTS="/system_contexts"
PRODUCTS="/products"

FAILED=0

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed. Run `sudo apt-get install jq`' >&2
  exit 1
fi

function echo_failed_message(){
    FAILED=$((FAILED + 1))
    message=$1
    echo -e "=== \033[31m FAIL \033[0m $message ==="
}
# verify json format
# using jq to parse json file
function is_fmt_json(){
    folder=$1
    for json in $(find .$folder -name "*.json"); do
        result=$(jq . $json 2>&1; echo "\n")
        if [[ ${result:0:1} != "{" ]]; then
            echo_failed_message "$PROJROOT${json:1}: invalid json!"
            exit 1
        fi
    done
}

# compare name,edition and component_type field with dirname of default.json
function validate_default_json_path(){
    # 1.name=component_type-edition
    # 2.default dirname = $components_root_path/$component_type/edition
    component_root_path=$1
    json=$2
    default_dirname=$(dirname $json)
    component_type=$(jq .'component_type' $json)
    edition=$(jq .'edition' $json)
    name=$(jq .'name' $json)

    if [[ ${name:1:0-1} != ${component_type:1:0-1}-${edition:1:0-1} ]]; then
        echo_failed_message "$json: wrong ['name', 'component_type', 'edition'] pair!"
    else
        if [[ $default_dirname != $component_root_path/${component_type:1:0-1}/${edition:1:0-1} ]]; then
            echo_failed_message "$json: dirname inconsistent with 'name' field!"
        fi
    fi
}

# check if every dependency in default.json can be found in the /components or /system_components
function validate_default_json_dependency(){
    component_root_path=$1
    json=$2
    key=$3
    dependencies=$(jq .$key $json)
    if [[ $dependencies != null ]];then
        dependencies=${dependencies:1:0-1}
        dependencies=${dependencies//,/}
        for dependency in $dependencies; do
            dep_path=$component_root_path/$dependency
            if [[ ! -d $dep_path ]];then
                echo_failed_message "$json: wrong dependency, cannot find $dependency in $component_root_path!"
            fi
        done
    fi
}


# validate directory: /components and /system_components
# validate the directory structure and some fields in default.json
function validate_components(){
    components_root_path=$1
    if [[ ! -d $components_root_path  ]]; then
        echo_failed_message "$components_root_path: not found!"
    else
        for component in $components_root_path/*; do
            if [[ ! -d $component ]];then
                echo_failed_message "$component: not a valid component directory!"
            else
            for version in $component/*; do
                if [[ ! -d $version ]];then
                    echo_failed_message $version:' not a valid version directory!'
                fi
            done
            fi
        done
    fi
}


# validate directory: /products
function validate_products(){
    product_root_path=$1
    components=$2
    if [[ ! -d $product_root_path  ]]; then
        echo_failed_message "$product_root_path: not found!"
    else
        for product in $product_root_path/*; do

            # validate /products/productX/category.json
            category=$product/category.json
            if [[ ! -f $category ]]; then
                echo_failed_message "$category: not found!"
            else
                category_name=$(jq .'category_name' $category)
                if [[ $category_name == null ]]; then
                    echo_failed_message "$category: missing category name!"
                else
                    if [[ ${category_name:1:0-1} != ${product##*/} ]]; then
                        echo_failed_message "$category: dirname not equals to category name!"
                    fi
                fi
            fi

            # check every directory in /products/productX
            # validate /products/productX/versionY/default.json
            for version in $(ls $product -F | grep "/$"); do
                product_default_file=$product/$version'default.json'
                if [[ ! -f $product_default_file ]];then
                    echo_failed_message "$product/$version: missing default.json!"
                else
                    # validate edition field
                    product_edition=$(jq .'edition' $product_default_file)
                    if [[ $product_edition == null ]];then
                        echo_failed_message "$product_default_file: missing edition!"
                    else
                        if [[ ${product_edition:1:0-1} != ${version:0:0-1} ]];then
                            echo_failed_message "$product_default_file: dirname not equals to edition!"
                        fi
                    fi

                    # validate components field
                    # every component in 'components' field should be a valid directory in /components
                    components=$(jq .'components' $product_default_file)
                    components=${components:1:0-1}
                    components=${components//,/}

                    for component in $components; do
                        component=${component:1:0-1}
                        prod_dft_version=$(echo $component | awk -F- '{print $NF}')
                        len=`expr ${#prod_dft_version} + 1`
                        prod_dft_component=${component:0:0-$len}
                        # components in products-default.json should be in the components directory
                        prod_dft_dir=$PROJROOT$COMPONENTS/$prod_dft_component/$prod_dft_version
                        if [[ ! -d $prod_dft_dir ]]; then
                            echo_failed_message "$product_default_file: wrong dependency, cannot find $prod_dft_component/$prod_dft_version in $PROJROOT$COMPONENTS"
                        fi
                    done
                fi
            done
        done
    fi

}


# validate directory: /system_context
function validate_sys_context(){
context_path=$1
if [[ ! -d $context_path  ]]; then
    echo_failed_message "$context_path: not found!"
else
for sys_context in $(ls $context_path | awk -F/ '{print $1}'); do
    if [[ ! -d $context_path/$sys_context ]];then
        echo_failed_message "$context_path/$sys_context: not a valid directory!"
    else
    for version in $(ls $context_path/$sys_context | awk -F/ '{print $1}'); do

        # validate default.json file in /contextX/versionY
        context_version_path=$context_path'/'$sys_context'/'$version
        context_default_file=$context_version_path'/default.json'
        if [[ ! -f $context_default_file ]]; then
            echo_failed_message "$context_default_file: not found!"
        else
            # compare name, version with dirname
            context_dft_name=$(jq .'name' $context_default_file)
            context_dft_version=$(jq .'edition' $context_default_file)
            if [[ $context_dft_version == null || $context_dft_name == null ]]; then
                echo_failed_message "$context_default_file : key error, name and edition cannot be null"
            else
                context_dft_name=${context_dft_name:1:0-1}
                context_dft_version=${context_dft_version:1:0-1}

                context_name=${context_dft_name/-$context_dft_version/}
                if [[ ${#context_name} == ${#context_dft_name} ]]; then
                    echo_failed_message "$context_default_file: wrong [name,edition] pair!"
                fi

                file_path_from_default=$context_path/${context_name//-/_}/$context_dft_version
                if [[ $file_path_from_default != $context_version_path ]]; then
                    echo_failed_message "$context_default_file: dirname inconsistent with 'name' value"
                fi
            fi

            # validate components field
            # every component in 'components' field should be a valid directory in /system_components
            sys_ctxt_components=$(jq .'components' $context_default_file)
            if [[ $sys_ctxt_components != null ]]; then
                sys_ctxt_components=${sys_ctxt_components:1:0-1}
                sys_ctxt_components=${sys_ctxt_components//,/}

                for sys_ctxt_dep in $sys_ctxt_components; do
                    sys_ctxt_dep=${sys_ctxt_dep:1:0-1}
                    sys_ctxt_version=$(echo $sys_ctxt_dep | awk -F- '{print $NF}')
                    len=`expr ${#sys_ctxt_version} + 1`
                    sys_ctxt_component=${sys_ctxt_dep:0:0-$len}
                    # components in system_context/version/default.json should be in the system_components directory
                    sys_ctxt_dir=$PROJROOT$SYS_COMPONENTS/$sys_ctxt_component/$sys_ctxt_version
                    if [[ ! -d $sys_ctxt_dir ]]; then
                        FAILED=$((FAILED + 1))
                        echo_failed_message "$context_default_file: wrong dependency, cannot find $sys_ctxt_component/$sys_ctxt_version in $context_path"
                    fi
                done
            fi
        fi
    done
    fi
done
fi
}


function is_test_failed() {
  echo
  if [[ $FAILED -eq 0 ]]; then
  	echo "Modules meta info declaration test pass."
        exit 0
  else
  	echo "FAILED: $FAILED."
        exit 1
  fi
}

is_fmt_json $COMPONENTS
is_fmt_json $PRODUCTS
is_fmt_json $RESOURCES
is_fmt_json $SYS_COMPONENTS
is_fmt_json $SYS_CONTEXTS

validate_components $PROJROOT$COMPONENTS
validate_components $PROJROOT$SYS_COMPONENTS
validate_products $PROJROOT$PRODUCTS $COMPONENTS
validate_sys_context $PROJROOT$SYS_CONTEXTS

is_test_failed
