import logging
import os
from tdc_commons.k8s.walm.operator import WalmChartOp
from tdc_commons.k8s import walm_base_config
import functools
import copy
import json
import codecs
import sys

logger = logging.getLogger(__name__)
CONFIGMAP = dict()


def config_updater(tag):
    """Decorator to handle with service setters"""

    def _typed_updater(func):
        CONFIGMAP[tag] = func

        @functools.wraps(func)
        def decorator(*args, **kwargs):
            return func(*args, **kwargs)

        return decorator

    return _typed_updater


@config_updater('cpu_limit')
def update_cpu_limit(key, value, name, desc, value_min, value_max, value_default):
    return {
        "description": desc + "可以使用的最大CPU core数量",
        "display_name": desc + "的CPU核数",
        "name": name + '_' + key,
        "value": value * value_default,
        "value_type": "cpu",
        "min": value_min * value,
        "max": value_max * value,
    }


@config_updater('cpu_request')
def update_cpu_request(key, value, name, desc, value_min, value_max, value_default):
    return {
        "description": desc + "分配的CPU core数量",
        "display_name": desc + "的CPU核数",
        "name": name + '_' + key,
        "value": value * value_default,
        "value_type": "cpu",
        "min": value_min * value,
        "max": value_max * value,
    }


@config_updater('memory_limit')
def update_mem_limit(key, value, name, desc, value_min, value_max, value_default):
    return {
        "description": desc + "可使用的最大内存",
        "display_name": desc + "的内存",
        "name": name + '_' + key,
        "value": value * value_default,
        "value_type": "memory",
        "min": value_min * value,
        "max": value_max * value
    }


@config_updater('memory_request')
def update_mem_request(key, value, name, desc, value_min, value_max, value_default):
    return {
        "description": desc + "分配的内存",
        "display_name": desc + "的内存",
        "name": name + '_' + key,
        "value": value * value_default,
        "value_type": "memory",
        "min": value_min * value,
        "max": value_max * value
    }


@config_updater('gpu_limit')
def update_gpu_limit(key, value, name, desc, value_min, value_max, value_default):
    return {
        "description": desc + "可以使用的最大GPU core数量",
        "display_name": desc + "GPU核数",
        "name": name + '_' + key,
        "value": value * value_default,
        "value_type": "gpu",
        "min": value_min * value,
        "max": value_max * value
    }


@config_updater('gpu_request')
def update_gpu_request(key, value, name, desc, value_min, value_max, value_default):
    return {
        "description": desc + "可分配的GPU core数量",
        "display_name": desc + "GPU核数",
        "name": name + '_' + key,
        "value": value * value_default,
        "value_type": "gpu",
        "min": value_min * value,
        "max": value_max * value
    }


@config_updater('storage')
def update_storage(key, value, name, desc, value_min, value_max, value_default):
    """
             {
                "name": "data",
                "storageType": "",
                "storageClass": "silver",
                "size": "500Gi",
                "accessModes": [
                  "ReadWriteOnce"
                ],
                "accessMode": ""
             },
    :param key:
    :param value:
    :param name:
    :param desc:
    :param value_min:
    :param value_max:
    :return:
    """

    def _format_storage(storage):
        return {
            "name": storage.get('name'),
            "type": storage.get('type'),
            "storageClass": storage.get('storage_class'),
            "size": storage.get('size'),
            "accessModes": storage.get('access_modes'),
            "accessMode": storage.get('access_mode')
        }

    return [
        {
            "description": desc + '可以使用的' + i.get('name') + '磁盘存储',
            "display_name": desc + "的" + i.get('name') + "磁盘大小",
            "name": name + '_' + i.get('name') + '_storage',
            "value": _format_storage(i),
            "value_type": "storage",
            "min": "0",
            "max": "51200"
        }
        for i in (value if value is not None else list())
    ]


class ResourceGenerator(object):
    # change one resouce to key value config
    # add max min, add unit, add cn and en
    def __init__(self, chart_name, chart_version, data):
        self.chart_name = chart_name
        self.chart_version = chart_version
        self.config = {}
        self.data = data
        resource = {
        }

        self.low = copy.deepcopy(resource)
        self.medium = copy.deepcopy(resource)
        self.high = copy.deepcopy(resource)

    def store_string(self):

        resource = [{
            "app_name": self.chart_name,
            "version": self.chart_version,
            "name": "low",
            "value": self.low
            },
            {
                "app_name": self.chart_name,
                "version": self.chart_version,
                "name": "medium",
                "value": self.medium
            },
            {
                "app_name": self.chart_name,
                "version": self.chart_version,
                "name": "high",
                "value": self.high
            }
        ]
        return json.dumps(resource)

    def update_config(self, data_dict, key, value, name, desc, index, value_min, value_max, value_default):
        config = CONFIGMAP[key](key, value, name, desc, value_min, value_max, value_default)
        if data_dict.get(name) is None:
            data_dict[name] = dict()
        data_dict[name][key] = config

    def add_items(self):
        """
          "description": "GovernorProxy服务可以使用的CPU core数量",
          "display_name": "GovernorProxy CPU核数",
          "name": "governor_proxy_cpu_limit",
          "value": "1.0",
          "value_type": "cpu",
          "min": "0",
          "max": "24"

          cpu_limit
          cpu_request
          gpu_limit
          gpu_request
          memory_limit
          memory_request
          storage
        :return:
        """
        for role in self.data['chart_pretty_params']['common_config']['roles']:
            index = self.data['chart_pretty_params']['common_config']['roles'].index(role)
            name = role.get('name')
            desc = role.get('description')
            for key, value in role.get('resouce_config', dict()).items():
                self.update_config(self.low, key, value, name, desc, index, value_min=0, value_max=5, value_default=1)
                self.update_config(self.medium, key, value, name, desc, index, value_min=0, value_max=5,
                                   value_default=2)
                self.update_config(self.high, key, value, name, desc, index, value_min=0, value_max=5, value_default=3)


class ConfigGenerator(object):
    # set PLATFORM_WALM_SERVICE_ADDRESS walm service address
    # walm  get list
    # create dir
    # walm get detail info
    # create config file
    # create relation file

    def __init__(self, address, root_dir, repo):
        os.putenv("PLATFORM_WALM_SERVICE_ADDRESS", address)
        walm_base_config.debug = True
        self.root_dir = root_dir
        self.chart_op = WalmChartOp()
        self.repo = repo

    def list_chart_configs(self):
        return self.chart_op.get_charts(repo_name=self.repo)

    def set_chart_configs(self, chart_name, chart_version):
        try:
            chart_info = self.chart_op.get_chart(self.repo, chart_name, chart_version)
        except Exception as e:
            logger.exception(e)
            logger.error("chart with {} - {} failed".format(chart_name, chart_version))
            return
        if not chart_info.chart_pretty_params:
            return
        if not chart_info.chart_pretty_params.common_config:
            return
        if not chart_info.chart_pretty_params.common_config.roles:
            return
        # need to mkdir
        self.mkdir(chart_name, chart_version)
        resource_info = ResourceGenerator(chart_name, chart_version, data=chart_info.to_dict())
        resource_info.add_items()
        with codecs.open(self.root_dir + '/' + chart_name + '/' + chart_version + '/config.json', 'w', 'utf-8') as f:
            f.write(resource_info.store_string())
            f.close()

    def mkdir(self, chart_name, version):
        if not os.path.exists(self.root_dir + '/' + chart_name):
            os.mkdir(path=self.root_dir + '/' + chart_name)
        if not os.path.exists(self.root_dir + '/' + chart_name + '/' + version):
            os.mkdir(path=self.root_dir + '/' + chart_name + '/' + version)
        os.open(path=self.root_dir + '/' + chart_name + '/' + version + '/config.json', flags=os.O_CREAT)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print('ERROR: input params error' + str(len(sys.argv)))
        exit(1)
    config_dir = sys.argv[1]
    addr = sys.argv[2]
    repo = sys.argv[3]
    configOp = ConfigGenerator(addr, config_dir,
                               repo)
    charts = configOp.list_chart_configs()
    for chart in charts:
        configOp.set_chart_configs(chart.chart_name, chart.chart_app_version)
