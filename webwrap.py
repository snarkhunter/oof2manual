#!/usr/bin/env python

# $RCSfile: webwrap.py,v $
# $Revision: 1.2 $
# $Author: langer $
# $Date: 2011-04-05 03:11:14 $

## This script wraps the html files for the OOF website and manual.
## It exists in two places within the OOF cvs repository:
## WEBPAGES/webwrap.py and MAN_OOF2/webwrap.py.  If changes are made
## to one of the files, they should be made to the other.

import sys
import os
import time
import re
import glob
import urllib
import shutil
import string
import getopt
import stat

def usage():
    print(
        """

Usage: ctcmsWeb.py --from=SOURCE --to=DEST [options]

Wrap html files with the standard CTCMS banner and side-bars.

SOURCE and DEST are directories.  SOURCE/* will be copied to DEST/*
recursively.  Non-html files will be copied verbatim, but html files
will be inserted into the CTCMS web template.  The files "meta.html",
"menu.html", and "logo.html" will also be inserted into the template,
if they exist.  They will not be copied to DEST.

The options are:
   --styledir=DIR      look in DIR for template.html, menu.html, etc.
   --exclude=SUFFIXES  don't copy any files whose suffixes are in the
                       comma-delimited list, eg, --exclude=.tex,.dvi,.log
""", file=sys.stderr)

def mod_time(file):
    return os.path.getmtime(file)

try:
    optlist, args = getopt.getopt(sys.argv[1:], '',
                                  ['from=', 'to=', 'styledir=', 'exclude='])
except getopt.error as message:
    print(message)
    usage()
    sys.exit(1)

# templateURL = "http://www.ctcms.nist.gov/CSS/template.html"
excludes = []
excludeddirs = ['CVS']
templateTime = None   # modification time for template file

styleDir = 'STYLE'
templatefiles = ['meta.html', 'menu.html', 'logo.html', 'template.html']
excludedfiles = templatefiles + ['simple_copy', 'Makefile', 'local', 'publish']

dataOrig = {}
for h in templatefiles:
    dataOrig[h] = ""

for opt in optlist:
    if opt[0] == '--from':
        fromPath = opt[1]
    elif opt[0] == '--to':
        toPath = opt[1]
    elif opt[0] == '--styledir':
        styleDir = opt[1]
    elif opt[0] == '--exclude':
        excludes = opt[1].split(',')

def readHTML(f, default = ""):
    try:
        htmlObj = open(f)
        html = htmlObj.read()
        htmlObj.close()
    except:
        html = default
        
    return html

headermodtime = None
for htmlName in templatefiles:
    fullname = os.path.join(fromPath, styleDir, htmlName)
    dataOrig[htmlName] = readHTML(fullname)
    if headermodtime is not None:
        headermodtime = max(headermodtime, mod_time(fullname))
    else:
        headermodtime = mod_time(fullname)

metaLen = len(dataOrig['meta.html'])
projectTitleRe = re.search('<title>(.*)</title>', dataOrig['meta.html'])
if projectTitleRe is None:
    projectTitle = raw_input('specify the project title: ')
    projectTitleStart = metaLen
    projectTitleEnd = metaLen
else:
    projectTitle = projectTitleRe.group(1)
    projectTitleStart = projectTitleRe.start()
    projectTitleEnd = projectTitleRe.end()
dataOrig['TITLE'] = '<h1 id="projectTitle">%s</h1>' % projectTitle

## Regular expressions used to search for something to use as the page
## title.  Each entry in the list is a tuple.  The first is a regular
## expression that contains at least one group [such as (.*?)].  The
## second is an integer which indicates which group contains the
## title.
exprs = [
    ('<h([1-6])\s*class="title"\s*.*?>(.*?)</h\\1>', 2), # <h1 class="title">...
    ('<th.*?>(.*?)</th>', 1)
    ]

def mergefile(srcname, dstname, root, simplecopylist):
    if (os.path.splitext(srcname)[1] != ".html"
        or os.path.basename(srcname) in simplecopylist):
        # Just copy non-html files
        try:
            # copyfile copies contents only, not permissions.
            shutil.copyfile(srcname, dstname)
        except:
            print("ctcmsWeb.py: shutil.copy failed", file=sys.stderr)
            raise
    else:
        # But process html files by inserting them in the template.

        data = {}

        data = dataOrig.copy()
        data['content.html'] = readHTML(srcname)

        for expr, groupno in exprs:
            pageTitleRe = re.search(expr, data['content.html'],
                                    re.DOTALL)
            if pageTitleRe: # strip out tags
                pageTitle = ''.join(
                    re.split('<.*?>', pageTitleRe.group(groupno)))
                break
        else:
            pageTitle = projectTitle

        projectTitleSub = '\n<title>%s</title>\n' % pageTitle

        data['meta.html'] = data['meta.html'][0:projectTitleStart] + \
                            projectTitleSub + \
                            data['meta.html'][projectTitleEnd:metaLen]

        mtime = time.localtime(os.stat(srcname).st_mtime)
        data['LASTMODIFIED'] = time.strftime(
            "%A, %d %B %Y %H:%M:%S %Z", mtime)
        # Substitute into the template.  *Don't* use
        # regular expressions, because the replacement
        # strings might contain character sequences that
        # happen to be re control sequences. (In
        # particular, '\g' can occur in tex code.)
        dt = data['template.html']
        for key in data.keys():
            if key != 'template.html':
                replaceme = '<!-- %s -->' % key.upper()
                dt = dt.replace(replaceme, data[key])

        # Some substitutions have to be done later, since they can
        # substitute for strings in the other substitutions.
        dt = dt.replace('$ROOT$', root)

        out = open(dstname, 'w')
        out.write(dt)
        out.close()


def mergetree(src, dst, root): 
    names = os.listdir(src) 
    
    try:
        os.mkdir(dst) 
    except os.error:
        pass

        

    # First, remove all files in dst that aren't in src.
    dstnames = os.listdir(dst)
    for dstfile in dstnames:
        fullpath = os.path.join(dst, dstfile)
        if dstfile not in names:
            if os.path.isdir(fullpath): # remove whole directory
                print("removing directory", fullpath)
                for subdir, dirs, files in os.walk(fullpath, topdown=False):
                    for name in files:
                        os.remove(os.path.join(subdir, name))
                    for name in dirs:
                        os.rmdir(os.path.join(subdir, name))
                os.rmdir(fullpath)
            else:
                print("removing file", fullpath)
                os.remove(fullpath)

    try:
        simplecopylist = [x.rstrip() for x in
                          open(os.path.join(src, "simple_copy"), "r").readlines()]
    except:
        simplecopylist = []
        
    for name in names: 
        srcname = os.path.join(src, name) 
        dstname = os.path.join(dst, name) 
        try: 
            if os.path.isdir(srcname):
                if os.path.basename(srcname) not in excludeddirs:
                    mergetree(srcname, dstname, '../'+root) 
            else:
                for excl in excludes:
                    if srcname[-len(excl):] == excl:
                        print("excluding", srcname)
                        break
                else:
                    # copy the file if the destination doesn't exist,
                    # or is out of date, but not if it's one of the
                    # three special files or if it's emacs cruft.
                    xclude = (name[0] == "." or
                              name[-1] == "~" or
                              name in excludedfiles)
                    if (not xclude and (not os.path.exists(dstname) or
                        (max(mod_time(srcname), headermodtime) >
                         mod_time(dstname)))):
                            print("merging", srcname, '->', dstname)
                            mergefile(srcname, dstname, root, simplecopylist)

        except (IOError, os.error) as why: 
            print(f"Can't copy {srcname} to {dstname}: {str(why)}")

            
mergetree(fromPath, toPath, root='.')

