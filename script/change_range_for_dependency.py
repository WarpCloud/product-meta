import sys
from ruamel import yaml
import codecs
from lib import read_file


if __name__ == '__main__':
    if len(sys.argv) < 4:
        print('ERROR: input params error' + str(len(sys.argv)))
        exit(1)

    path = sys.argv[1]
    release_version = sys.argv[2]
    dependency_version = sys.argv[3]
    dependency_range = sys.argv[4].split('/')
    rc_or_final_map = dict()
    files = read_file(path, 'images.yaml')
    for item in files.items():
        is_change=False
        file_name = item[0]
        template = item[1]
        releases = item[1].get('releases')
        for release in releases:
            release_ver = release.get('release-version')
            if release_ver != release_version:
                continue
            for dependency in release.get('dependencies'):
                max_version = dependency.get('max-version')
                if max_version == dependency_version:
                    is_change = True
                    dependency['max-version'] = dependency_range[0]
                    dependency['min-version'] = dependency_range[1]
        if is_change:
            str = yaml.dump(template, Dumper=yaml.RoundTripDumper, indent=2)
            with codecs.open(file_name, 'w', 'utf-8') as f:
                f.write(str)
                f.close()
