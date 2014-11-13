#!/usr/bin/env python

import re, sys

number_re = re.compile('^[0-9]+$')

def extract_coordinate(part):
	## print 'PART', part
	return part.split(']')[0]

def extract_coordinates(name):
	return map(extract_coordinate, name.split('[')[1:])

def allowed(importer, imported):
	if importer == imported:
		return None
	if number_re.match(importer) and number_re.match(imported):
		importer_number = int(importer)
		imported_number = int(imported)
		if imported_number <= importer_number:
			return True
	print 'DISALLOWED', importer, imported
	return False

def filter(importer_name, imported_name):
	importer = extract_coordinates(importer_name)
	imported = extract_coordinates(imported_name)
	## print 'COORDINATES', importer, imported
	while importer and imported:
		status = allowed(importer[0], imported[0]) # Can be either True, False, or None
		if status != None:
			return status
		del importer[0]
		del imported[0]
	if importer:
		print 'DISALLOWED', importer[0], '?'
		return False
	return True

while True:
	line = sys.stdin.readline()
	if not line: break
	if line[-1:] == '\n': line = line[:-1]
	dummy, importer, imported = line.split(':')
	## print 'NAMES', importer, imported
	if not filter(importer, imported):
		print 'WARNING', importer, imported
