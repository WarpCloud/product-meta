# coding:utf-8
import os
import sys
from ruamel import yaml
from copy import deepcopy
import codecs


def read_file(path, change_file):
    files = os.listdir(path)
    file_dict = dict()
    for file in files:
        file_name = path + '/' + file;
        if os.path.isdir(file_name):
            temp_dict = file_dict.copy()
            temp_dict.update(read_file(path + '/' + file, change_file))
            file_dict = temp_dict
        elif file == change_file:
            f = codecs.open(file_name, 'r', 'utf-8')
            iter_f = iter(f)
            str = ''
            for line in iter_f:
                str += line
            file_dict[file_name] = yaml.load(str, Loader=yaml.RoundTripLoader)
    return file_dict


if __name__ == '__main__':
    if len(sys.argv) != 6:
        print('ERROR: input params error' + str(len(sys.argv)))
        exit(1)

    path = sys.argv[1]
    root_version = sys.argv[2].split('/')
    update_version = sys.argv[3].split('/')
    is_final = True if sys.argv[4] == 'true' else False
    exclude = sys.argv[5].split('/')
    files = read_file(path, 'images.yaml')
    for item in files.items():
        file_name = item[0]
        template = item[1]
        releases = item[1].get('releases')
        if template.get('instance-type') == 'sophon':
            continue
        is_change = False
        releases_new = list()
        hot_fix_range = list()
        is_rc_update = False
        for hot_fix in item[1].get('hot-fix-ranges'):
            if 'rc' in hot_fix.get('max'):
                # there is rc0, update to rc1
                version = hot_fix.get('max').split('rc')
                for update in update_version:
                    if version[0] in update:
                        hot_fix['max'] = update
                        is_rc_update = True
                        continue
            if hot_fix.get('max') not in root_version:
                continue
            if is_rc_update:
                continue
            # add new rc or final hot_fix version
            hot_fix_new = deepcopy(hot_fix)
            hot_fix['max'] = update_version[root_version.index(hot_fix.get('max'))]
            hot_fix['min'] = update_version[root_version.index(hot_fix.get('min'))]
            hot_fix_range.append(hot_fix_new)
            continue
        for hot_fix in hot_fix_range:
            template['hot-fix-ranges'].append(hot_fix)
        for release in releases:
            if release.get('release-version') not in root_version:
                releases_new.append(release)
                continue
            # add new
            is_change = True
            release_origin = deepcopy(release)
            for dependency in release.get('dependencies'):
                change_version = dependency.get('max-version')
                dependency['max-version'] = update_version[root_version.index(change_version)]
                dependency['min-version'] = update_version[root_version.index(change_version)]
            for images in release.get('image-version').items():
                image_value = update_version[root_version.index(images[1])]
                if image_value is not None:
                    release['image-version'][images[0]] = image_value

            release['release-version'] = update_version[root_version.index(release.get('release-version'))]
            release['final'] = is_final
            releases_new.append(release)
            releases_new.append(release_origin)
        template['releases'] = releases_new
        if is_change:
            str = yaml.dump(template, Dumper=yaml.RoundTripDumper, indent=2)
            with codecs.open(file_name, 'w', 'utf-8') as f:
                f.write(str)
                f.close()
