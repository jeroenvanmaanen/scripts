#!/usr/bin/env python

# An alternative for the docker command that produces machine-readable output.

import re
import string
import sys
from docker.client import Client
from docker.utils import kwargs_from_env


def print_list(label, value):
    value_type = type(value)
    ## print '{label}: {value_type}'.format(**locals())
    if value_type == type([]):
        i = 0
        for item in value:
            i += 1
            print_list("{label}[{i}]".format(**locals()), item)
    elif value_type == type({}):
        dict_keys = value.keys()[:]
        dict_keys.sort()
        ## print '{label}: {dict_keys}'.format(**locals())
        for key in dict_keys:
            item = value[key]
            print_list("{label}.{key}".format(**locals()), item)
    else:
        print '{label}: {value}'.format(**locals())


class Trie():
    def __init__(self, s):
        self._children = {}
        self._s = s

    def add(self, s):
        if not s:
            return
        first = s[0]
        remainder = s[1:]
        if self._s:
            t = self._s
            self._s = None
            self.add(t)
        if not first in self._children:
            sub_trie = Trie(s)
            self._children[first] = sub_trie
        else:
            sub_trie = self._children[first]
            sub_trie.add(remainder)

    def depth(self):
        result = 0
        for sub_trie in self._children.values():
            result = max(result, sub_trie.depth() + 1)
        return result


def value(string_argument):
    if not string_argument:
        return string_argument
    elif string_argument[0] == '.':
        return string_argument[1:]
    elif re.match('(True|False|[0-9]+([.][0-9]+))$', string_argument):
        return eval(string_argument)
    else:
        return string_argument


def main(*arguments_tuple):
    string_arguments = map(None, arguments_tuple)
    if string_arguments and string_arguments[0] == '-h':
        print '''\
Usage: docker-cli.py [ -k <id-key> [-p[<n>]] ] [--] <command> <argument>...
       docker-cli.py -h'''
        return None
    id_key = None
    unique_prefix = None
    if string_arguments and string_arguments[0] == '-k':
        id_key = string_arguments[1]
        del string_arguments[:2]
        if string_arguments and re.match('-p[1-9][0-9]*$', string_arguments[0]):
            number = string_arguments[0][2:]
            del string_arguments[0]
            if number:
                unique_prefix = string.atoi(number)
            else:
                unique_prefix = 1
    if string_arguments and string_arguments[0] == '--':
        del string_arguments[0]

    arguments = []
    keyword_arguments = {}
    command = string_arguments[0]
    for string_argument in string_arguments[1:]:
        if string_argument[:2] == '--':
            pos = string.find(string_argument, '=')
            if pos < 0:
                keyword_arguments[string_argument[2:]] = True
            else:
                keyword_arguments[string_argument[2:pos]] = value(string_argument[pos+1:])
        else:
            arguments.append(value(string_argument))
    ## print 'ARGUMENTS', arguments
    ## print 'KEYWORD ARGUMENTS', keyword_arguments
    method = client.__getattribute__(command)
    result = apply(method, arguments, keyword_arguments)
    if type(result) == type([]):
        trie = Trie('')
        if unique_prefix:
            for item in result:
                if id_key in item:
                    trie.add(item[id_key])
            unique_prefix = max(unique_prefix, trie.depth())
        i = 0
        for item in result:
            i += 1
            if id_key and id_key in item:
                item_id = str(item[id_key])
                if unique_prefix:
                    item_id = item_id[:unique_prefix]
                item_id = '@' + item_id
            else:
                item_id = '#' + repr(i)
            print_list(item_id, item)
            print

# See http://docker-py.readthedocs.org/en/latest/boot2docker/
kwargs = kwargs_from_env()
kwargs['tls'].assert_hostname = False

client = Client(**kwargs)

if __name__ == '__main__':
    main(*sys.argv[1:])
