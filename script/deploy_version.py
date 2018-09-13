# coding:utf-8
import os
import sys
from ruamel import yaml
from copy import deepcopy
import codecs
import copy
from lib import read_file


if __name__ == '__main__':
    if len(sys.argv) < 6:
        print('ERROR: input params error' + str(len(sys.argv)))
        exit(1)

    path = sys.argv[1]
    root_version = sys.argv[2].split('/')
    update_version = sys.argv[3].split('/')
    is_final = True if sys.argv[4] == 'true' else False
    exclude = sys.argv[5].split('/')
    if len(sys.argv) == 7:
        update_release = sys.argv[6].split('/')
    else:
        update_release = copy.deepcopy(root_version)
    rc_or_final_map = dict()
    for update in update_version:
        if 'final' in update:
            rc_or_final_map[update] = 'final'
        else:
            rc_or_final_map[update] = 'rc'
    files = read_file(path, 'images.yaml')
    for item in files.items():
        file_name = item[0]
        template = item[1]
        releases = item[1].get('releases')
        if template.get('instance-type') in exclude:
            continue
        is_change = False
        releases_new = list()
        hot_fix_range = list()
        is_rc_update = dict()
        for version in root_version:
            is_rc_update[version] = False
        for hot_fix in item[1].get('hot-fix-ranges'):
            if 'rc' in hot_fix.get('max'):
                # there is rc0, update to rc1
                version = hot_fix.get('max').split('rc')
                for update in update_version:
                    if version[0] in update:
                        if rc_or_final_map[update] != 'rc':
                            continue
                        hot_fix['max'] = update
                        for root_is_exist in root_version:
                            if root_is_exist in version[0]:
                                is_rc_update[root_is_exist] = True
                                break
                        continue
            if 'final' in hot_fix.get('max'):
                version = hot_fix.get('max').split('-')
                for update in update_version:
                    if version[0] in update:
                        hot_fix['max'] = update
                        if rc_or_final_map[update] != 'final':
                            continue
                        for root_is_exist in root_version:
                            if root_is_exist in version[0] + '-' + version[1]:
                                is_rc_update[root_is_exist] = True
                                break
                        continue
            if hot_fix.get('max') not in update_release:
                continue
            if is_rc_update.get(hot_fix.get('max')) is None or is_rc_update.get(hot_fix.get('max')):
                continue
            # add new rc or final hot_fix version
            hot_fix_new = deepcopy(hot_fix)
            hot_fix['max'] = update_version[update_release.index(hot_fix.get('max'))]
            hot_fix['min'] = update_version[update_release.index(hot_fix.get('min'))]
            hot_fix_range.append(hot_fix_new)
            continue
        for hot_fix in hot_fix_range:
            template['hot-fix-ranges'].append(hot_fix)
        for release in releases:
            if release.get('release-version') in update_version:
                # TODO: update version
                for dependency in release.get('dependencies'):
                    change_version = dependency.get('max-version')
                    for version in update_release:
                        if version in change_version:
                            dependency['max-version'] = update_version[root_version.index(version)]
                            is_change = True
            if release.get('release-version') not in update_release:
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
