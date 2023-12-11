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

OOF.Help.API_Listing(filename='oof2_api.xml', format='xml')
OOF.File.Quit()
