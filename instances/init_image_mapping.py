import os, errno
import json
import yaml

products_default_file = '/root/workspace/tdc/product-meta/etc/ockle/products_default.yml'

jsonnet_root_dir = '/root/workspace/tdc/application-jsonnet'

app_root_dir = '/root/workspace/tdc/product-meta/dependencies/applications'

target_root_dir = '/root/workspace/tdc/product-meta/instances/image_mapping'

min_ockle_version = '0.1.4'


def convertible_to_float(element):
    try:
        float(element)
        return True
    except ValueError:
        return False


def safe_mkdirs(directory):
    try:
        os.makedirs(directory)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise


if __name__ == '__main__':
    #
    image_map = {}
    all_vars_in_products_default = []

    with open(products_default_file) as f:
        products_default = yaml.load(f)

    for product, var_map in products_default.iteritems():
        for k, v in var_map.iteritems():
            if '_image' in k:
                image_map[k] = v
                all_vars_in_products_default.append(k)
    # print image_map

    # (instance_type, version) -> [variable_name]
    variable_map = {}
    all_vars_in_jsonnet = []
    for root, dirs, files in os.walk(jsonnet_root_dir):
        if 'app.yaml' in files:
            app_yaml_path = os.path.join(root, 'app.yaml')
            with open(app_yaml_path) as f:
                app_yaml = yaml.load(f)
            instance_type, version = app_yaml['name'], str(app_yaml['version'])
            variables = []
            if not 'userConfig' in app_yaml:
                continue
            for configTab in app_yaml['userConfig']['configTabs']:
                for config in configTab['configs']:
                    if '_image' in config['name']:
                        variables.append(config['name'])
                        all_vars_in_jsonnet.append(config['name'])
            variable_map[(instance_type, version)] = variables

            del dirs[:]
    # print variable_map

    #
    apps = os.listdir(app_root_dir)

    instance_yaml_map = {}  # instance_type ->
    for app in apps:
        # print app,
        app_dir = os.path.join(app_root_dir, app)
        versions = os.listdir(app_dir)
        max_version = max(versions, key=lambda v: float(v))
        # print max_version
        golden_path = os.path.join(app_dir, max_version, 'test-files', 'config_dependency.jsonnet.golden')
        with open(golden_path) as f:
            golden = json.load(f)

        for instance in golden[u'instance_list']:
            images_yaml = {}
            instance_yaml_map[instance[u'moduleName']] = images_yaml

            images_yaml['instance-type'] = instance[u'moduleName'].encode('utf-8')
            images_yaml['major-version'] = instance[u'version'].encode('utf-8')
            images_yaml['min-ockle-version'] = min_ockle_version
            images_yaml['images'] = []
            images_yaml['releases'] = []

            release0 = {
                'instance-version': '',
                'final': False,
                'image-version': {},
                'dependencies': []
            }
            images_yaml['releases'].append(release0)

            instance_type = instance[u'moduleName'].encode('utf-8')
            instance_version = instance[u'version'].encode('utf-8')
            if (instance_type, instance_version) in variable_map:
                image_vars = variable_map[(instance_type, instance_version)]
                for var in image_vars:
                    if var not in image_map:
                        print 'not found in image_map', var
                        continue
                    link = image_map[var]
                    images_yaml['images'].append({
                        'variable': var,
                        'name': link[link.rfind('/') + 1:link.rfind(':')]
                    })
                    image_tag = link[link.rfind(':') + 1:]
                    if image_tag > release0['instance-version']:
                        release0['instance-version'] = image_tag
                        release0['final'] = 'final' in image_tag
                    release0['image-version'][var] = image_tag
            else:
                print 'not found', instance_type, instance_version

            # prepare dependencies
            if u'dependencies' in instance:
                for dependency in instance[u'dependencies']:
                    release0['dependencies'].append({
                        'type': dependency[u'moduleName'].encode('utf-8')
                    })
            else:
                release0['dependencies'] = []

            images_yaml['hot-fix-ranges'] = [{
                'min': release0['instance-version'], 'max': release0['instance-version']
            }]

    for instance_type_u, instance_yaml in instance_yaml_map.iteritems():
        for dependency in instance_yaml['releases'][0]['dependencies']:
            dependency_type_u = dependency['type'].decode('utf-8')
            if dependency_type_u in instance_yaml_map:
                dependency_version = instance_yaml_map[dependency_type_u]['releases'][0]['instance-version']
                dependency['min-version'] = dependency_version
                dependency['max-version'] = dependency_version

    print instance_yaml_map

    for instance_type_u, instance_yaml in instance_yaml_map.iteritems():
        dir_path = os.path.join(target_root_dir, instance_type_u, instance_yaml['major-version'])
        safe_mkdirs(dir_path)
        yaml_path = os.path.join(dir_path, 'images.yaml')
        with open(yaml_path, 'w') as f:
            yaml.dump(instance_yaml, f, default_flow_style=False)
