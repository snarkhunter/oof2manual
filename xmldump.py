# -*- python -*-
# This software was produced by NIST, an agency of the U.S. government,
# and by statute is not subject to copyright in the United States.
# Recipients of this software assume all responsibilities associated
# with its operation, modification and maintenance. However, to
# facilitate maintenance we ask that before distributing modified
# versions of this software, you first contact the authors at
# oof_manager@nist.gov.

# This script is run by OOF2 to produce the xml file for part of the
# reference section of the manual, documenting all of the menu items
# and RegisteredClasses, and some other bits and pieces.

# Some menus aren't constructed until a graphics window is opened.

OOF.Windows.Graphics.New()

# Get the ids from the xml files other than oof2_api.xml. This lets
# the code in SRC/common/IO/xmlmenudump.py sort cross references in
# oof2_api.xml in a sensible way.

import re
# Regexp pattern that matches id="idtag" or id='idtag'.  It defines
# two groups. This first is just the opening quotation mark, which is
# in a group so that it can be compared to the closing quotation mark.
# The second group is the idtag.
pattern = re.compile(r"""id=(["'])(.+?)\1""") 

xmlids = {}                     # xmlids[id] = order
sourcefiles = open("xmlfilelist", "r")
for fline in sourcefiles:
    filename = fline.strip()
    if filename and filename[0] != '#':
        srcfile = open(filename, "r")
        for srcline in srcfile:
            # This might include commented out lines, but that
            # shouldn't matter.  Adding them to the dict won't change
            # the ordering of the other ids.
            for r in pattern.findall(srcline):
                # findall returns a list of strings that match the two
                # groups defined in the regexp pattern.  The second
                # group is the docbook id.
                xmlids[r[1]] = len(xmlids)

# Don't use an OOF2 menu item to generate the manual.  It's not
# something that users will do, and not something that needs to be
# logged.  Also, xmlids is too large to use as an OOFMenuItem
# argument, since it will be echoed to the screen.  Just call
# xmlmenudump directly.

from ooflib.common.IO import xmlmenudump
outfile = open('oof2_api.xml', 'w')
xmlmenudump.xmlmenudump(outfile, xmlids)
outfile.close()

OOF.File.Quit()
