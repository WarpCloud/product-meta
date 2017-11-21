#!/usr/bin/env bash
# Testing module for product-meta

set -e

FILEPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
PROJROOT=$(cd $(dirname $FILEPATH) && pwd)
COMPONENTS="/components"
SYS_COMPONENTS="/system_components"
CONTEXTS="/system_contexts"
PRODUCTS="/products"
LIBAPPADAPTER="/dependencies"
LIBAPPADAPTER_PATH="/applications"


# verify json format
# using jq to parse json file
function format_all_json(){
    for json in $(find ./ -name "*.json"); do
        result=$(jq . $json 2>&1; echo "\n")
        if [[ ${result:0:1} != "{" ]]; then
            echo -e "=== \033[31m $PROJROOT${json:1}: invalid json! ${result:0:0-3}\033[0m=== " 1>&2
            exit 1
        fi
    done
}

# compare name,edition and component_type field with dirname of default.json
validate_default_json_path(){
    # 1.name=component_type-edition
    # 2.default dirname = $components_root_path/$component_type/edition
    component_root_path=$1
    json=$2
    default_dirname=$(dirname $json)
    component_type=$(jq .'component_type' $json)
    edition=$(jq .'edition' $json)
    name=$(jq .'name' $json)

    if [[ ${name:1:0-1} != ${component_type:1:0-1}-${edition:1:0-1} ]]; then
        echo -e "=== \033[31m $json: wrong ['name', 'component_type', 'edition'] pair! \033[0m=== " 1>&2
    else
        if [[ $default_dirname != $component_root_path/${component_type:1:0-1}/${edition:1:0-1} ]]; then
            echo -e "=== \033[31m $json: dirname inconsistent with 'name' field! \033[0m=== " 1>&2
        fi
    fi
}

# check if every dependency in default.json can be found in the /components or /system_components
validate_default_json_dependency(){
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
                echo -e "=== \033[31m $json: wrong dependency, cannot find $dependency in $component_root_path! \033[0m=== " 1>&2
            fi
        done
    fi
}

# every components should be a part of libappadapter/dependencies
validate_libappadapter_dependency(){
    component_path=$1
    product_component=$2
    libappadapter_path=$PROJROOT$LIBAPPADAPTER$LIBAPPADAPTER_PATH
    if [[ ! -d $libappadapter_path/$product_component ]]; then
        echo -e "=== \033[31m $component_path/$product_component: wrong dependency, cannot find /$product_component in $libappadapter_path! \033[0m=== " 1>&2
    fi
}

# validate directory: /components and /system_components
# validate the directory structure and some fields in default.json
validate_components(){
    components_root_path=$1

    if [[ ! -d $components_root_path  ]]; then
        echo -e "=== \033[31m $components_root_path: not found! \033[0m=== " 1>&2
    else
        for component in $components_root_path/*; do
            if [[ ! -d $component ]];then
                echo -e "=== \033[31m $component: not a valid component directory! \033[0m=== " 1>&2
            else
            for version in $component/*; do
                if [[ ! -d $version ]];then
                    echo -e "=== \033[31m $version: not a valid version directory! \033[0m=== " 1>&2
                else
                    # check if every component is in libappadapter
                    component_subdir=$(basename $component)/$(basename $version)
                    validate_libappadapter_dependency $components_root_path $component_subdir
                    default_json_file=$version/default.json
                    if [[ ! -f $default_json_file ]]; then
                        echo -e "=== \033[31m $default_json_file: not found! \033[0m=== " 1>&2
                    else
                        # if /components/componentX/versionY/default.json exists, validate default.json field
                        validate_default_json_path $components_root_path $default_json_file
                        validate_default_json_dependency $component_root_path $default_json_file dependencies

                    fi
                fi
            done
            fi
        done
    fi
}


# validate directory: /products
validate_products(){
    product_root_path=$1
    components=$2
    if [[ ! -d $product_root_path  ]]; then
        echo -e "=== \033[31m $product_root_path: not found! \033[0m=== " 1>&2
    else
        for product in $product_root_path/*; do

            # validate /products/productX/category.json
            category=$product/category.json
            if [[ ! -f $category ]]; then
                echo -e "=== \033[31m $category: not found! \033[0m=== " 1>&2
            else
                category_name=$(jq .'category_name' $category)
                if [[ $category_name == null ]]; then
                    echo -e "=== \033[31m $category: missing category name! \033[0m=== " 1>&2
                else
                    if [[ ${category_name:1:0-1} != ${product##*/} ]]; then
                        echo -e "=== \033[31m $category: dirname not equals to category name! \033[0m=== " 1>&2
                    fi
                fi
            fi

            # check every directory in /products/productX
            # validate /products/productX/versionY/default.json
            for version in $(ls $product -F | grep "/$"); do
                product_default_file=$product/$version'default.json'
                if [[ ! -f $product_default_file ]];then
                    echo -e "=== \033[31m $product/$version: missing default.json! \033[0m=== " 1>&2
                else
                    # validate edition field
                    product_edition=$(jq .'edition' $product_default_file)
                    if [[ $product_edition == null ]];then
                        echo -e "=== \033[31m $product_default_file: missing edition! \033[0m=== " 1>&2
                    else
                        if [[ ${product_edition:1:0-1} != ${version:0:0-1} ]];then
                            echo -e "=== \033[31m $product_default_file: dirname not equals to edition! \033[0m=== " 1>&2
                        fi
                    fi

                    # validate components field
                    # every component in 'components' field should be a valid directory in /components
                    components=$(jq .'components' $product_default_file)
                    components=${components:1:0-1}
                    components=${components//,/}

                    for component in $components; do
                        component=${component:1:0-1}
                        prod_dft_component=$(echo $component | awk -F- '{print $1}')
                        prod_dft_version=$(echo $component | awk -F- '{print $2}')

                        # components in products-default.json should be in the components directory
                        prod_dft_dir=$PROJROOT$COMPONENTS/$prod_dft_component/$prod_dft_version
                        if [[ ! -d $prod_dft_dir ]]; then
                            echo -e "=== \033[31m $product_default_file: wrong dependency, cannot find $prod_dft_component/$prod_dft_version in $PROJROOT$COMPONENTS \033[0m=== " 1>&2
                        fi
                    done
                fi
            done
        done
    fi

}


# validate directory: /system_context
validate_sys_context(){
context_path=$1
if [[ ! -d $context_path  ]]; then
    echo -e "=== \033[31m $context_path: not found! \033[0m=== " 1>&2
else
for sys_context in $(ls $context_path | awk -F/ '{print $1}'); do
    if [[ ! -d $context_path/$sys_context ]];then
        echo -e "=== \033[31m $context_path/$sys_context: not a valid directory! \033[0m=== " 1>&2
    else
    for version in $(ls $context_path/$sys_context | awk -F/ '{print $1}'); do

        # validate default.json file in /contextX/versionY
        context_version_path=$context_path'/'$sys_context'/'$version
        context_default_file=$context_version_path"/default.json"
        if [[ ! -f $context_default_file ]]; then
            echo -e "=== \033[31m $context_default_file: not found! \033[0m=== " 1>&2
        else
            # compare name, version with dirname
            context_dft_name=$(jq .'name' $context_default_file)
            context_dft_version=$(jq ."edition" $context_default_file)
            if [[ $context_dft_version == null || $context_dft_name == null ]]; then
                echo -e "=== \033[31m context_default_file : key error, name and edition cannot be null\033[0m=== " 1>&2
            else
                context_dft_name=${context_dft_name:1:0-1}
                context_dft_version=${context_dft_version:1:0-1}

                context_name=${context_dft_name/-$context_dft_version/}
                if [[ ${#context_name} == ${#context_dft_name} ]]; then
                    echo -e "=== \033[31m $context_default_file: wrong [name,edition] pair!\033[0m=== " 1>&2
                fi

                file_path_from_default=$context_path/${context_name//-/_}/$context_dft_version
                if [[ $file_path_from_default != $context_version_path ]]; then
                    echo -e "=== \033[31m $context_default_file: dirname inconsistent with 'name' value \033[0m=== " 1>&2
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
                    sys_ctxt_component=$(echo $sys_ctxt_dep | awk -F- '{print $1}')
                    sys_ctxt_version=$(echo $sys_ctxt_dep | awk -F- '{print $2}')

                    # components in system_context/version/default.json should be in the system_components directory
                    sys_ctxt_dir=$PROJROOT$SYS_COMPONENTS/$sys_ctxt_component/$sys_ctxt_version
                    if [[ ! -d $sys_ctxt_dir ]]; then
                        echo -e "=== \033[31m $context_default_file: wrong dependency, cannot find $sys_ctxt_component/$version in $context_path\033[0m=== " 1>&2
                    fi
                done
            fi
        fi
    done
    fi
done
fi
}

$PROJROOT$LIBAPPADAPTER/run_test.sh
format_all_json

validate_components $PROJROOT$COMPONENTS
validate_components $PROJROOT$SYS_COMPONENTS
validate_products $PROJROOT$PRODUCTS $COMPONENTS
validate_sys_context $PROJROOT$CONTEXTS