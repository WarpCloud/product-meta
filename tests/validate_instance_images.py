#!/usr/bin/env python3
from pathlib import Path

import yaml
import json
import os

from flex_version import FlexVersion
from verminator.validate_release_dep import *

# Customized version suffix ordering
FlexVersion.ordered_suffix = ['rc', 'final', None]


def scan_products(root_dir, final_versions=None):
    """
    Scan pick version project directories
    """
    products_instance = list()
    rp = Path(root_dir)
    products = [x for x in rp.iterdir() if x.is_dir()]
    for product in products:
        product = product.name
        product_dir_path = Path(rp.joinpath(product))
        versions = [x for x in product_dir_path.iterdir() if x.is_dir()]
        for version in versions:
            version = version.name
            if final_versions is not None and version not in final_versions:
                continue
            vpath = product_dir_path.joinpath(version)
            # Check existance of default.json
            json_path = vpath.joinpath('default.json')
            assert Path(json_path).exists(), \
                'File default.json absent for {}/{}'.format(product, version)
            with open(json_path, encoding="UTF-8") as f:
                product = json.load(f)
                products_instance.append(Product(product, json_path, version))
    return products_instance


if __name__ == '__main__':
    proj_root = Path(__file__).parent.parent

    # Scan and validate images declaration
    scan_instances(proj_root.joinpath('instances'))

    # Each dependence should have at least a pre-defined version
    validate_dependence_versions()

    # products = scan_products(proj_root.joinpath('products'))
