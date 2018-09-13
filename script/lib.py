import os
from ruamel import yaml
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
