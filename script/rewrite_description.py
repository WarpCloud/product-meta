#!/usr/bin/env python
from argparse import ArgumentParser
import os
import io
import json


def rewrite_component_files(directory, component_type, version):
    files_dir = os.path.join(directory, component_type, version)
    print('Rewriting {}'.format(files_dir))

    default_file = os.path.join(files_dir, 'default.json')
    price_file = os.path.join(files_dir, 'price.json')

    if os.path.isfile(default_file):
        with io.open(default_file, 'r', encoding='utf-8') as outfile:
            data = json.load(outfile)

        data['edition'] = version
        data['name'] = '{}-{}'.format(component_type, version)

        with io.open(default_file, 'w', encoding='utf-8') as outfile:
            json.dump(data, outfile, indent=2, ensure_ascii=False)

    if os.path.isfile(price_file):
        with io.open(price_file, 'r', encoding='utf-8') as outfile:
            data = json.load(outfile)

        data['edition'] = version
        data['name'] = '{}-{}'.format(component_type, version)

        with io.open(price_file, 'w', encoding='utf-8') as outfile:
            json.dump(data, outfile, indent=2, ensure_ascii=False)


def remove_useless_description_from_product_files(directory):
    files_dir = os.path.join(directory)

    for category_name in os.listdir(files_dir):
        for ver in os.listdir(os.path.join(files_dir, category_name)):
            default_file = os.path.join(files_dir, category_name, ver, 'default.json')
            if os.path.isfile(default_file):
                with io.open(default_file, 'r', encoding='utf-8') as outfile:
                    data = json.load(outfile)

                rewritten = False
                if 'templates' in data:
                    del data['templates']
                    rewritten = True

                if 'is_distributed' in data:
                    del data['is_distributed']
                    rewritten = True

                if rewritten:
                    with io.open(default_file, 'w', encoding='utf-8') as outfile:
                        json.dump(data, outfile, indent=2, ensure_ascii=False)
                    print('%s rewritten' % default_file)

if __name__ == '__main__':
    path = os.getenv('PROJROOT')
    prods_path = path + '/products'
    comps_path = path + '/components'

    parser = ArgumentParser()
    parser.add_argument(dest="type")
    parser.add_argument(dest="method")
    parser.add_argument("-c", "--component", dest="component_type")
    parser.add_argument("-v", "--version", dest="version")
    args = parser.parse_args()

    if args.type == 'component':
        if args.method == 'validate':
            rewrite_component_files(comps_path, args.component_type, args.version)

    if args.type == 'product':
        if args.method == 'rm-useless':
            remove_useless_description_from_product_files(prods_path)
