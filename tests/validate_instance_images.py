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


# def get_relation(instance_relation, product, applications):
#     def is_exist_in_relation(type, relation):
#         for comp in relation:
#             if comp.get('type') == type:
#                 return comp
#         return False


#     def create_relation(apps, instance_relation, applications, product_component):
#         instances = list()
#         for app in apps:
#             check_instance = is_exist_in_relation(app.type, instance_relation)
#             if check_instance is not False:
#                 # exist continue to next component
#                 instances.append(check_instance)
#                 continue
#             else:
#                 instance_comp_dependency = list()
#                 dependencies = app.dependencies
#                 for dependency in dependencies:
#                     is_not_exist_in_product = True
#                     for component in product_component:
#                         application = applications[component.name + '-' + component.version]
#                         for application_dependency in application:
#                             if dependency.type == application_dependency.type:
#                                 application_list = [application_dependency]
#                                 instance_comp_dependency.extend(create_relation(application_list, instance_relation, applications, product_component))
#                                 is_not_exist_in_product = False

#                     if is_not_exist_in_product:
#                         # TODO: product doesn't has dependency application instance
#                         pass

#                 instance = {
#                     'id': app.type+'-'+app.version,
#                     'type': app.type,
#                     'major-version': app.version,
#                     'dependencies': instance_comp_dependency
#                 }
#                 instance_relation.append(instance)
#                 instances.append(instance)
#         return instances

#     for component in product.component:
#         application = applications[component.name+'-'+component.version]
#         create_relation(application, instance_relation, applications, product.component)
#     return instance_relation


# def validate_product_version(products, applications):
#     from tdc_commons.meta.product_meta_manager import ProductMetaManager
#     from tdc_commons.meta.resource_loader import FileSystemResourceLoader

#     resource_loader = FileSystemResourceLoader(os.getenv('PROJROOT'))
#     product_meta = ProductMetaManager(resource_loader)
#     for product in products:
#         if product.edition == '5.1':
#             min_tdc_version = 'tdc-1.0.0-rc0'
#         # elif product.edition == '5.2':
#         #     min_tdc_version = 'tdc-1.1.0-rc0'
#         else:
#             continue
#         instance_relateion = list()
#         get_relation(instance_relateion, product, applications)

#         try:
#             image_links = product_meta.find_latest_images(
#                 instance_relation=instance_relateion,
#                 tdc_version=min_tdc_version,
#                 show_rc=False,
#                 registry_base='172.16.1.99/transwarp',
#                 should_in_registry=False
#             )
#             print('check product {}.{}'.format(product.name, product.edition))
#         except Exception:
#             assert False, "product {}.{} has a error".format(product.name, product.edition)
#         assert (len(image_links) > 0)
#         for image in image_links:
#             assert (len(image['image-links']) > 0)


if __name__ == '__main__':
    proj_root = Path(__file__).parent.parent

    # Scan and validate images declaration
    # scan_instances(proj_root.joinpath('instances'))

    # Each dependence should have at least a pre-defined version
    # validate_dependence_versions()

    products = scan_products(proj_root.joinpath('products'))
    print(products)

