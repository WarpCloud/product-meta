# coding:utf-8
import json
import os


class Product(object):
    def __init__(self, version, file_dir):
        self.version = version

        desc_file = os.path.join(file_dir, 'default.json')
        assert os.path.isfile(desc_file)

        self.desc = json.load(open(desc_file, encoding='utf-8'))

    def test_resources(self, validate_assets):
        print('Checking Product {} resources'.format(self.version))
        resources = self.desc.get('resources', list())
        if len(resources) > 0:
            for r in resources:
                assert 'type' in r
                assert 'name' in r
                assert r['name'] in validate_assets


class Category(object):
    def __init__(self, name, file_dir):
        self.name = name

        desc_file = os.path.join(file_dir, 'category.json')
        assert os.path.isfile(desc_file)

        self.desc = json.load(open(desc_file, encoding='utf-8'))

        versions = list()
        for p_dir in os.listdir(file_dir):
            if os.path.isdir(os.path.join(file_dir, p_dir)):
                versions.append(p_dir)
        self.products = [Product(v, os.path.join(file_dir, v)) for v in versions]

    def test_resources(self, validate_assets):
        print('Checking Category {} resources'.format(self.name))
        resources = self.desc.get('resources', list())
        if len(resources) > 0:
            for r in resources:
                assert 'type' in r
                assert 'name' in r
                assert r['name'] in validate_assets

        for p in self.products:
            p.test_resources(validate_assets)


if __name__ == '__main__':
    path = os.getenv('PROJROOT')
    products_path = path + '/products'
    assert os.path.isdir(products_path)

    categories = [Category(n, os.path.join(products_path, n)) for n in os.listdir(products_path)]

    assets_path = path + '/assets'
    validate_assets = set(os.listdir(assets_path))
    [c.test_resources(validate_assets) for c in categories]
