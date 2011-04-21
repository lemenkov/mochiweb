#!/usr/bin/env python

from lxml import etree
import sys
import re

def usage(name):
	print 'usage: %s /path/to/shared/mime/freedesktop.org.xml' % name

def print_mime(Ext, Desc):
	if ext.match(Ext):
		print "from_extension(\"%s\") ->\n    \"%s\";" % (Ext[1:], Desc)

def print_mime_test(Ext, Desc):
	if ext.match(Ext):
		print "    ?assertEqual(\"%s\",\n                 from_extension(\"%s\"))," % (Desc, Ext[1:])

if __name__ == '__main__':
	if len(sys.argv) != 2:
		usage(sys.argv[0])
		sys.exit(1)

	doc = etree.parse ( sys.argv[1] )
	root = doc.getroot()
	ext = re.compile("\*\.[a-zA-Z]*")

	print \
		"%% @author Bob Ippolito <bob@mochimedia.com>\n" \
		"%% @author Peter Lemenkov <lemenkov@mochimedia.com>\n" \
		"%% @copyright 2007-2011 Mochi Media, Inc.\n\n"\
		"%% @doc Gives a good MIME type guess based on file extension.\n"\
		"%%      Generated by ../support/parse_mime.py\n\n"\
		"-module(mochiweb_mime).\n"\
		"-author('bob@mochimedia.com').\n"\
		"-export([from_extension/1]).\n\n"\
		"%% @spec from_extension(S::string()) -> string() | undefined\n"\
		"%% @doc Given a filename extension (e.g. \".html\") return a guess for the MIME\n"\
		"%%      type such as \"text/html\". Will return the atom undefined if no good\n"\
		"%%      guess is available.\n"

	for e in sorted(root, key=lambda x: str(x.tag)):
		for ie in e:
			if ie.tag == "{http://www.freedesktop.org/standards/shared-mime-info}glob":
				print_mime(ie.get("pattern"), e.get("type"))

	print "from_extension(_) ->\n    undefined.\n"

	print \
			"%%\n"\
			"%% Tests\n"\
			"%%\n\n"\
			"-ifdef(TEST).\n"\
			"-include_lib(\"eunit/include/eunit.hrl\").\n\n"\
			"exhaustive_from_extension_test() ->\n"\
			"    T = mochiweb_cover:clause_lookup_table(?MODULE, from_extension),\n"\
			"    [?assertEqual(V, from_extension(K)) || {K, V} <- T].\n\n"\
			"from_extension_test() ->"

	for e in root:
		for ie in e:
			if ie.tag == "{http://www.freedesktop.org/standards/shared-mime-info}glob":
				print_mime_test(ie.get("pattern"), e.get("type"))

	print \
			"    ?assertEqual(undefined,\n                 from_extension(\"\")),\n"\
			"    ?assertEqual(undefined,\n                 from_extension(\".wtf\")),\n"\
			"    ok.\n\n"\
			"-endif."

