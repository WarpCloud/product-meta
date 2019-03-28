import json
import os
import codecs
import sys


# 'http://172.16.3.232:31842'
class ConfigCenterSet(object):
    def __init__(self, address):
        from hamurapi_client.api_client import ApiClient
        from hamurapi_client.configuration import Configuration as hamurapiCilentConfiguration
        from hamurapi_client.api import ConfigSetControllerApi, AppVersionControllerApi
        print("store in config center")
        hamurapi_client_config = hamurapiCilentConfiguration()
        hamurapi_client_config.host = address
        _api_client = ApiClient(configuration=hamurapi_client_config)
        self.config_api = ConfigSetControllerApi(api_client=_api_client)
        self.app_version_api = AppVersionControllerApi(api_client=_api_client)

    def store_config(self, data):
        from hamurapi_client.models import AppVersionCreationDTO
        app_name = data[0].get('app_name')
        version = data[0].get('version')
        try:
            self.app_version_api.delete_using_delete(
                repo_name='stable',
                app_name=app_name, version=version)
        except Exception as e:
            print("needn't delete config set : {}".format(app_name))

        app_version_creation_dto = AppVersionCreationDTO(repo_name='stable',
                                                         app_name=app_name,
                                                         version=version)
        self.app_version_api.create_using_post(app_version_creation_dto)
        for i in data:
            config_dto = self.config_api.create_by_app_version_using_post(
                repo_name='stable',
                app_name=app_name,
                version=version,
                info={
                    "comment": "ockle",
                    "configSetName": i.get('name'),
                    "format": "JSON"
                })
            body = {
                "value": i.get("value")
            }
            self.config_api.import_items_using_put(config_dto.id, body, publish=True)
        print('finish call config center')

    def get_config(self, path):
        file_dict = self.read_dir(path)
        for name, value in file_dict.items():
            data = json.loads(value)
            for i in data:
                i['app_name'] = i['app_name'] + '_template'
                i['value'] = json.dumps(i['value'])
            self.store_config(data)

    def get_jsonnet(self, path):
        file_dict = self.read_dir(path)
        root_name = ''
        jsonnet_config = list()
        for name, value in file_dict.items():
            names = name.split('/')
            root_name = names[1]
            jsonnet_config.append({'name': names[2], 'value': value})
        resource = {
            "app_name": root_name,
            "version": "tdc-2.0",
            "configSets": [
                {
                    "changedBy": "admin",
                    "comment": "string",
                    "configItems": [
                        {
                            "changedBy": "string",
                            "createdBy": "string",
                            "description": "string",
                            "descriptionEng": "string",
                            "name": i.get('name'),
                            "readOnly": False,
                            "schema": "string",
                            "type": "string",
                            "value": i.get('value'),
                            "key": i.get('name')
                        }
                    ],
                    "createdBy": "admin",
                    "format": "string",
                    "name": i.get('name'),
                    "key": i.get("name")
                } for i in jsonnet_config
            ]
        }
        self.store_config(resource)

    def read_dir(self, path, dir_path=''):
        files = os.listdir(path)
        file_dict = dict()
        for file in files:
            file_name = path + '/' + file
            new_path = dir_path + '/' + file
            if os.path.isdir(file_name):
                temp_dict = file_dict.copy()
                temp_dict.update(self.read_dir(path + '/' + file, dir_path=new_path))
                file_dict = temp_dict
            else:
                f = codecs.open(file_name, 'r', 'utf-8')
                iter_f = iter(f)
                str = ''
                for line in iter_f:
                    str += line
                file_dict[new_path] = str
        return file_dict


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('ERROR: input params error' + str(len(sys.argv)))
        exit(1)
    config_dir = sys.argv[1]
    addr = sys.argv[2]
    config_op = ConfigCenterSet(address=addr)
    config = config_op.get_config(config_dir)
