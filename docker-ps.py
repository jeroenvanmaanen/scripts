#!/usr/bin/env python

# An alternative for the docker ps command that produces machine-readable output.

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

# See http://docker-py.readthedocs.org/en/latest/boot2docker/
kwargs = kwargs_from_env()
kwargs['tls'].assert_hostname = False

client = Client(**kwargs)
containers = client.containers(all=True)
trie = Trie('')
for container in containers:
    trie.add(container['Id'])
prefix_length = max(trie.depth(), 6)
print "Prefix length: {prefix_length}".format(**locals())

for container in containers:
    container_id = container['Id']
    print_list(container_id[:prefix_length], container)
    print
