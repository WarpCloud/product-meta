#!/usr/bin/env python
from argparse import ArgumentParser
import os
import io
import json


def rewrite_files(directory, component_type, version):
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

if __name__ == '__main__':
    path = os.getenv('PROJROOT')
    comps_path = path + '/components'

    parser = ArgumentParser()
    parser.add_argument("-c", "--component", dest="component_type")
    parser.add_argument("-v", "--version", dest="version")
    args = parser.parse_args()
    rewrite_files(comps_path, args.component_type, args.version)
