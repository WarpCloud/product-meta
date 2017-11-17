import yaml
import os
import re
import json
import logging

TEMPLATES_FOLDER = './libappadapter/templates'
APPLICATION_INSTANCE_METAINFO_DIR = os.path.join('../application-metainfo')
INSTANCE_ADVANCED_CONFIGS_DIR = 'instances/instance_advanced_configs'

logger = logging.getLogger(__name__)


def get_instance_advanced_configs(instance_type, version, configurations=None):
    """
    Get default advanced configs for the specific application instance
    :param instance_type: type of the application instance
    :param version: version of the application instance
    :param configurations: configurations of the application instance gathered from configuration.yaml
    :return: instance_advanced_configs
    """
    advanced_configs = []
    if configurations is not None:
        for configuration in configurations:
            name = configuration.get('name', '')
            default_value = str(configuration.get('recommendExpression', ''))
            value_type = configuration.get('valueType', '')
            groups = configuration.get('groups', [])
            if value_type in ['KB', 'MB', 'GB']:
                default_value += value_type
            advanced_config = {
                'name': name,
                'value': default_value,
                'default': default_value,
                'groups': groups
            }
            advanced_configs.append(advanced_config)

    instance_advanced_configs = {
        'configs': advanced_configs,
        'instance_type': instance_type,
        'version': version
    }
    return instance_advanced_configs


def init_instances_advanced_configs():
    """
    Initialize default advanced configs for application instances.
    Generate advanced_configs.json file for every version of an application instance,
    located at templates/instance_advanced_configs/
    :return: True
    """
    regex_version = r'transwarp-(\d+(\.\d+)*)'

    def construct_service_level(loader, node):
        return loader.construct_mapping(node)

    def construct_role_types(loader, node):
        return loader.construct_mapping(node)

    yaml.add_constructor(u"ServiceLevel", construct_service_level)
    yaml.add_constructor(u"RoleTypes", construct_role_types)

    try:
        for instance_type in os.listdir(APPLICATION_INSTANCE_METAINFO_DIR):
            for _version in os.listdir(os.path.join(APPLICATION_INSTANCE_METAINFO_DIR, instance_type)):
                # get version
                m = re.match(regex_version, _version)
                if m is None:
                    continue
                version = m.group(1)
                instance_type = instance_type.lower()

                # make directory to place the advanced_configs.json file
                instance_advanced_configs_dir = os.path.join(TEMPLATES_FOLDER,
                                                             INSTANCE_ADVANCED_CONFIGS_DIR,
                                                             instance_type, version)
                if not os.path.exists(instance_advanced_configs_dir):
                    os.makedirs(instance_advanced_configs_dir)

                # get application instance advanced configs
                with open(os.path.join(APPLICATION_INSTANCE_METAINFO_DIR, instance_type.upper(), _version, 'configuration.yaml')) as f:
                    configurations = yaml.load(f)
                instance_advanced_configs = get_instance_advanced_configs(instance_type, version, configurations)

                with open(os.path.join(instance_advanced_configs_dir, 'advanced_configs.json'), 'w') as json_file:
                    json_file.write(json.dumps(instance_advanced_configs, indent=2))
                logger.info('Initializing advanced configs of application instance %s, version: %s' % (instance_type, version))

    except IOError as ie:
        logger.error('Error occurred when initializing default application instance advanced configs: %s' % ie.message)
        return False

    return True


if __name__ == '__main__':
    init_instances_advanced_configs()
