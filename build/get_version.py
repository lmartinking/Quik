#!/usr/bin/env python2.7

from xml.etree import ElementTree as etree

def get_version(project_file):
	with open(project_file) as proj:
		tree = etree.parse(proj)

		root = tree.getroot()		

		for elem in root.iter("app"):
			if 'version' in elem.attrib:
				return elem.attrib['version']

	return None


if __name__ == '__main__':
	import sys

	version = None

	if len(sys.argv) == 2:
		version = get_version(sys.argv[1])

	if not version:
		sys.exit(1)

	print version
	sys.exit(0)
