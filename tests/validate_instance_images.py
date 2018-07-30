#!/usr/bin/env python3
from pathlib import Path

import yaml
import json
import os

from flex_version import FlexVersion


class ReleaseDep(object):
    def __init__(self, dep_desc):
        self.type = dep_desc['type']
        self.max_version = dep_desc['max-version']
        self.min_version = dep_desc['min-version']


class ApplicationDep(object):
    def __init__(self, name, module_name, ori_version):
        self.type = module_name
        self.name = name
        self.version = ori_version


class Application(object):
    def __init__(self, instance, name):
        self.dependencies = list()
        self.name = name
        self.type = instance.get('moduleName')
        self.version = instance.get('version')
        if instance.get('dependencies') is not None:
            for dependency in instance.get('dependencies'):
                self.dependencies.append(ApplicationDep(name, dependency.get('moduleName'), self.version))


class Product(object):
    def __init__(self, product, json_path, version):
        self.component = list()
        name = str(json_path).split('products/')[1]
        name = name.split('/')[0]
        self.name = name
        self.edition = version
        components = product.get('components')
        for component in components:
            name = component.split('-')[0].upper()
            version = component.split('-')[1].lower()
            self.component.append(Component(name, version))


class Component(object):
    def __init__(self, name, version):
        self.name = name
        self.version = version


class ReleaseInfo(object):
    # All metainfo of versioned instances:
    # {instance: {version: ReleaseInfo}}
    __instance_releases = dict()

    def __init__(self, instance_name, release_version, is_final, instance_version, dependencies=None):
        self.instance_name = instance_name
        self.release_version = release_version
        self.is_final = is_final
        self.instance_version = instance_version
        if dependencies:
            self.dependencies = [ReleaseDep(i) for i in dependencies]
        else:
            self.dependencies = list()

    @classmethod
    def add_release(cls, instance_name, release_desc, instance_version):
        release_version = release_desc['release-version']
        is_final = release_desc['final']
        image_version = release_desc['image-version']
        dep_desc = release_desc['dependencies']

        release = ReleaseInfo(instance_name, release_version, is_final, instance_version, dep_desc)

        if instance_name not in cls.__instance_releases:
            cls.__instance_releases[instance_name] = dict()
        if release.release_version not in cls.__instance_releases[instance_name]:
            cls.__instance_releases[instance_name][release.release_version] = dict()
        else:
            assert False, 'Duplicated release version {} for {}' \
                .format(release.release_version, instance_name)
        cls.__instance_releases[instance_name][release.release_version] = release

        return release

    @classmethod
    def all_instance_releases(cls):
        return cls.__instance_releases


def scan_instances(root_dir):
    """
    Scan all instances directories
    """
    rp = Path(root_dir)
    instances = [x for x in rp.iterdir() if x.is_dir()]
    for instance in instances:
        instance = instance.name
        inspath = Path(rp.joinpath(instance))
        versions = [x for x in inspath.iterdir() if x.is_dir()]
        for version in versions:
            version = version.name
            vpath = inspath.joinpath(version)
            imgpath = vpath.joinpath('images.yaml')
            assert Path(imgpath).exists(), \
                'File images.yaml absent for {}/{}'.format(instance, version)
            images = yaml.load(open(imgpath))

            # Validate images meta info
            validate_versioned_image(images, instance, version)


def scan_project(root_dir, final_version):
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
            if version not in final_version:
                continue
            vpath = product_dir_path.joinpath(version)
            json_path = vpath.joinpath('default.json')
            assert Path(json_path).exists(), \
                'File default.json absent for {}/{}'.format(product, version)
            f = open(json_path, encoding="UTF-8")
            iter_f = iter(f)
            str = ''
            for line in iter_f:
                str += line
            product = json.loads(str)
            products_instance.append(Product(product, json_path, version))
    return products_instance


def scan_applications(root_dir):
    applications = dict()
    rp = Path(root_dir)
    applications_dir_path = [x for x in rp.iterdir() if x.is_dir()]
    for application in applications_dir_path:
        application_name = application.name
        application_path = Path(rp.joinpath(application_name))
        versions = [x for x in application_path.iterdir() if x.is_dir()]
        for version in versions:
            version = version.name
            vpath = application_path.joinpath(version).joinpath('test-files').joinpath(
                'config_dependency.jsonnet.golden')
            if not vpath.is_file():
                assert False, 'add test case plz for {}'.format(vpath)
            f = open(vpath)
            iter_f = iter(f)
            str = ''
            for line in iter_f:
                str += line
            app = json.loads(str)
            instance_list = app.get('instance_list')
            instance_app = list()
            for instance in instance_list:
                instance_app.append(Application(instance, application_name))
            applications[application_name + '-' + version] = instance_app
    return applications


def validate_versioned_image(images, instance_name, instance_version):
    """
    Validate the meta info of images defined for each instance
    """
    print('Validating versioned {}, {}'.format(instance_name, instance_version))
    assert images['instance-type'].lower() == instance_name.lower()
    assert images['major-version'] == instance_version
    assert 'images' in images
    assert 'releases' in images
    assert 'min-tdc-version' in images
    assert 'hot-fix-ranges' in images

    # Collect all releases of instances
    releases = dict()
    for r in images.get('releases', list()):
        release_info = ReleaseInfo.add_release(instance_name, r, instance_version)
        releases[release_info.release_version] = release_info

    # Validate hot-fix range: each defined release should be in a hot-fix range
    hot_fixes = images.get('hot-fix-ranges', list())
    for rv in releases:
        found = False
        for fix_range in hot_fixes:
            if FlexVersion.in_range(rv, minv=fix_range['min'], maxv=fix_range['max']):
                found = True
        assert found, 'Release version {} of {} not in a valid hot-fix range' \
            .format(rv, instance_name)

    # Validate dependence min-max range: min <= max
    for release_info in releases.values():
        for dep in release_info.dependencies:
            res = FlexVersion.compares(dep.min_version, dep.max_version)
            assert res <= 0, 'Invalid min-max range [min: {}, max: {}] for version {} of {}' \
                .format(dep.min_version, dep.max_version, release_info.release_version, instance_name)


def _find_a_ranged_version(instance_name, minv, maxv):
    """
    Given a version range, check if a valid version is defined in the range.
    """
    all_instance_releases = ReleaseInfo.all_instance_releases()
    versions = all_instance_releases.get(instance_name, dict())
    found = False
    for v, release_info in versions.items():
        found = FlexVersion.in_range(v, minv, maxv)
        if found:
            break
    return found


def validate_dependence_versions():
    """
    Each dependence should have at least a version defined.
    """
    print('Total {} instances defined'.format(len(ReleaseInfo.all_instance_releases())))
    all_instance_releases = ReleaseInfo.all_instance_releases()

    # Validate dependencies: each dependence should have a valid
    # version as in defined range
    for instance_name, versions in all_instance_releases.items():
        for instance_version, release_info in versions.items():
            print('Validating dependence of {} version {}'.format(release_info.instance_name, instance_version))
            dependencies = release_info.dependencies
            for dep in dependencies:
                dep_type = dep.type
                minv = dep.min_version
                maxv = dep.max_version

                assert dep_type in all_instance_releases, \
                    "No dependence found {} for version {} of {}" \
                        .format(dep_type, instance_version, instance_name)

                found = _find_a_ranged_version(dep_type, minv=minv, maxv=maxv)
                assert found, "No valid version defined for {} with max: {}, min: {}" \
                    .format(dep_type, maxv, minv)


def get_relation(instance_relation, product, applications):
    def is_exist_in_relation(type, relation):
        for comp in relation:
            if comp.get('type') == type:
                return comp
        return False


    def create_relation(apps, instance_relation, applications, product_component):
        instances = list()
        for app in apps:
            check_instance = is_exist_in_relation(app.type, instance_relation)
            if check_instance is not False:
                # exist continue to next component
                instances.append(check_instance)
                continue
            else:
                instance_comp_dependency = list()
                dependencies = app.dependencies
                for dependency in dependencies:
                    is_not_exist_in_product = True
                    for component in product_component:
                        application = applications[component.name + '-' + component.version]
                        for application_dependency in application:
                            if dependency.type == application_dependency.type:
                                application_list = [application_dependency]
                                instance_comp_dependency.extend(create_relation(application_list, instance_relation, applications, product_component))
                                is_not_exist_in_product = False

                    if is_not_exist_in_product:
                        # TODO: product doesn't has dependency application instance
                        pass

                instance = {
                    'id': app.type+'-'+app.version,
                    'type': app.type,
                    'major-version': app.version,
                    'dependencies': instance_comp_dependency
                }
                instance_relation.append(instance)
                instances.append(instance)
        return instances

    for component in product.component:
        application = applications[component.name+'-'+component.version]
        create_relation(application, instance_relation, applications, product.component)
    return instance_relation


def validate_product_version(products, applications):
    from tdc_commons.meta.product_meta_manager import ProductMetaManager
    from tdc_commons.meta.resource_loader import FileSystemResourceLoader

    resource_loader = FileSystemResourceLoader(os.getenv('PROJROOT'))
    product_meta = ProductMetaManager(resource_loader)
    for product in products:
        if product.edition == '5.1':
            min_tdc_version = 'tdc-1.0.0-rc0'
        # elif product.edition == '5.2':
        #     min_tdc_version = 'tdc-1.1.0-rc0'
        else:
            continue
        instance_relateion = list()
        get_relation(instance_relateion, product, applications)

        try:
            image_links = product_meta.find_latest_images(
                instance_relation=instance_relateion,
                tdc_version=min_tdc_version,
                show_rc=False,
                registry_base='172.16.1.99/transwarp',
                should_in_registry=False
            )
            print('check product {}.{}'.format(product.name, product.edition))
        except Exception:
            assert False, "product {}.{} has a error".format(product.name, product.edition)
        assert (len(image_links) > 0)
        for image in image_links:
            assert (len(image['image-links']) > 0)


if __name__ == '__main__':
    proj_root = Path(__file__).parent.parent

    scan_instances(proj_root.joinpath('instances'))

    products = scan_project(proj_root.joinpath('products'), ['5.1'])

    application = scan_applications(proj_root.joinpath('applications').joinpath('applications'))

    validate_dependence_versions()

    validate_product_version(products, application)
