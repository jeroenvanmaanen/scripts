# record.py

import re, sys

def log(*args): pass

no_id_re = re.compile('[^A-Za-z_]+')
cap_re = re.compile(' ([a-z]?)')

def split_fields(line):
    return str(line).split('\t')

def to_name(s):
    name = no_id_re.sub(' ', s)
    name = cap_re.sub(lambda m: m.group(1).upper(), name)
    name = name.strip()
    return name

def batch(argv, splitter = split_fields):
    field_names = []
    data = []
    if not argv: argv = ['-']
    log('Arguments', argv)
    for name in argv:
        if name == '-':
            file = sys.stdin
        else:
            file = open(name, 'rU')
        file = File(file, data, splitter)
        file.process(field_names)
    return data, field_names

def write_tsv(data, field_names, file = sys.stdout):
    log('Length of data', len(data))
    if data:
        file.write('\t'.join(field_names) + '\n')
        for record in data:
            fields = []
            for name in field_names:
                if name in record:
                    fields.append(str(record[name]))
                else:
                    fields.append('')
            file.write('\t'.join(fields) + '\n')

class Record(dict):
    def __init__(self, header, fields):
        for name, value in map(None, header, fields):
            if name: self[name] = value

class File:
    def __init__(self, file, data = None, splitter = split_fields):
        self._file = file
        if data == None:
            data = []
        self._data = data
        self._splitter = splitter
    def readline(self):
        line = self._file.readline()
        if not line: return None
        if line[-1:] == '\n': line = line[:-1]
        return line
    def parse_header(self):
        line = self.readline()
        if line is None: return None
        fields = self._splitter(line)
        field_names = map(to_name, fields)
        log('Field names', field_names)
        return field_names
    def process(self, field_names = None):
        log('Process file', self._file)
        if field_names is None: field_names = []
        header = self.parse_header()
        if header is None: raise ErrorMessage, 'Missing header'
        for name in header:
            if name not in field_names: field_names.append(name)
        lines = []
        while True:
            line = self.readline()
            if line is None: break
            ## log('line', line)
            lines.append(line)
        lines.sort()
        for line in lines:
            fields = self._splitter(line)
            record = Record(header, fields)
            ## log('Record', record)
            self._data.append(record)
        return field_names
