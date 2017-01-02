# Translate CSV files to TSV files

import exceptions, re, sys

from record import batch, write_tsv

field_re = re.compile('"([^"]*)"')


class CsvException(exceptions.Exception): pass


def split_fields(line):
    fields = []
    tail = line
    if tail:
        while True:
            m = field_re.match(tail)
            if not m: raise CsvException, ('Field expected', tail)
            field = m.group(1)
            fields.append(field)
            tail = tail[m.end(0):]
            if not tail: break
            if tail[0] != ',': raise CsvException, ('Comma or end of line expected', tail)
            tail = tail[1:]
    ## log('Fields', fields)
    return fields

data, field_names = batch(sys.argv[1:], split_fields)

if len(sys.argv) > 0:
    ## print "Argv:", sys.argv
    pass

write_tsv(data, field_names)
