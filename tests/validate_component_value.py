# coding:utf-8
import os
import json
import codecs


def read_file(path):
    files = os.listdir(path)
    file_dict = dict()
    for file in files:
        file_name = path + '/' + file;
        if os.path.isdir(file_name):
            temp_dict = file_dict.copy()
            temp_dict.update(read_file(path + '/' + file))
            file_dict = temp_dict
        elif file == 'default.json':
            f = codecs.open(file_name, 'r', 'utf-8')
            iter_f = iter(f)
            str = ''
            for line in iter_f:
                str += line
            file_dict[file_name] = json.loads(str)
    return file_dict


if __name__ == '__main__':
    path = os.getenv('PROJROOT')
    path = path + '/components'
    files = read_file(path)
    for item in files.items():
        file_name = item[0]
        template = item[1].get('templates')
        name = str(file_name).split("components")[1]
        print("checking file {}".format(name))
        if template is None:
            continue
        for configs in template:
            for object in configs.get('configs'):
                assert object.get('value_type') != None
                assert object.get('value') != None
                assert object.get('name') != None
                assert object.get('display_name') != None
                assert object.get('description') != None
                assert object.get('min') !=None
                assert object.get('max') !=None
