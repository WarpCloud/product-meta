# coding:utf-8
import yaml
import os


class OckleFile(object):
    def __init__(self, file_dir):
        settings_file = os.path.join(file_dir, 'settings.yml')
        assert os.path.isfile(settings_file)
        self.settings = yaml.load(open(settings_file, encoding='utf-8'), Loader=yaml.FullLoader)

    def test_service_description(self, validate_assets):
        for chart_name, d_svcs in self.settings.get('service_description', dict()).items():
            print('Checking Chart {} service description'.format(chart_name))
            for d_svc in d_svcs:
                assert 'port' in d_svc
                assert 'select_name' in d_svc
                if 'resource_name' in d_svc:
                    assert d_svc['resource_name'] in validate_assets


if __name__ == '__main__':
    path = os.getenv('PROJROOT')

    file_path = path + '/etc/ockle'
    assert os.path.isdir(file_path)

    assets_path = path + '/assets'
    assert os.path.isdir(assets_path)
    assets_name = set(os.listdir(assets_path))

    ockle_file = OckleFile(file_dir=file_path)
    ockle_file.test_service_description(validate_assets=assets_name)
