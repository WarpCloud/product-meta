# coding:utf-8
import json
import os


class ModuleMeta(object):
    def __init__(self):
        self.desc = dict()

    def test_resources(self, validate_assets):
        resources = self.desc.get('resources', list())
        if len(resources) > 0:
            for r in resources:
                assert 'type' in r
                assert 'name' in r
                assert r['name'] in validate_assets


class Component(ModuleMeta):
    def __init__(self, type, version, file_dir):
        super(Component, self).__init__()
        self.type = type
        self.version = version

        desc_file = os.path.join(file_dir, 'default.json')
        assert os.path.isfile(desc_file)

        self.desc = json.load(open(desc_file, encoding='utf-8'))

    def test_resources(self, validate_assets):
        print('Checking Component {}-{} static resources'.format(self.type, self.version))
        super(Component, self).test_resources(validate_assets=validate_assets)


class Product(ModuleMeta):
    def __init__(self, type, version, file_dir):
        super(Product, self).__init__()
        self.type = type
        self.version = version

        desc_file = os.path.join(file_dir, 'default.json')
        assert os.path.isfile(desc_file)

        self.desc = json.load(open(desc_file, encoding='utf-8'))

    def test_resources(self, validate_assets):
        print('Checking Product {}-{} static resources'.format(self.type, self.version))
        super(Product, self).test_resources(validate_assets=validate_assets)


class Category(ModuleMeta):
    def __init__(self, name, file_dir):
        super(Category, self).__init__()
        self.name = name

        desc_file = os.path.join(file_dir, 'category.json')
        assert os.path.isfile(desc_file)

        self.desc = json.load(open(desc_file, encoding='utf-8'))

        versions = list()
        for p_dir in os.listdir(file_dir):
            if os.path.isdir(os.path.join(file_dir, p_dir)):
                versions.append(p_dir)
        self.products = [Product(self.name, v, os.path.join(file_dir, v)) for v in versions]

    def test_resources(self, validate_assets):
        print('Checking Category {} static resources'.format(self.name))
        super(Category, self).test_resources(validate_assets=validate_assets)

        for p in self.products:
            p.test_resources(validate_assets)


if __name__ == '__main__':
    path = os.getenv('PROJROOT')

    products_path = path + '/products'
    assert os.path.isdir(products_path)

    components_path = path + '/components'
    assert os.path.isdir(components_path)

    assets_path = path + '/assets'
    assert os.path.isdir(assets_path)

    assets_name = set(os.listdir(assets_path))
    categories = [Category(n, os.path.join(products_path, n)) for n in os.listdir(products_path)]
    [c.test_resources(assets_name) for c in categories]
    components = [Component(type=t, version=v, file_dir=os.path.join(components_path, t, v))
                  for t in os.listdir(components_path) for v in os.listdir(os.path.join(components_path, t))]
    [c.test_resources(assets_name) for c in components]