# -*- python -*-

# This software was produced by NIST, an agency of the U.S. government,
# and by statute is not subject to copyright in the United States.
# Recipients of this software assume all responsibilities associated
# with its operation, modification and maintenance. However, to
# facilitate maintenance we ask that before distributing modified
# versions of this software, you first contact the authors at
# oof_manager@nist.gov. 

# This is a hack that converts the latex equations in the OOF2 manual
# to MathML.  The equations are written inside the docbook files in
# the form
#
#    <inlineequation>
#      <alt role="tex">
#        \( a = b \)
#       </alt>
#    </inlineequation>
#
# for inline equations, or
#
#    <equation id="pythagoras">
#      <alt role="tex">
#          \[ x^2 + y^2 = z^2 \]
#      </alt>
#    </equation>
#
# for displayed equations.  The id in the <equation> tag is optional.
#
# The initial processing of the equations is done by templates in
# latex-math.xsl.  (xsl/oofchunk.xsl is given as an argument to saxon in
# Makefile. oofchunk.xsl imports xsl/oofhtml.xsl, which imports
# xsl/latex-math/xsl/latex-math.xsl.)
#
# Saxon and latex-math.xsl produce two tex files,
# tex-math-equations.tex and tex-math-inlines.tex, along with the html
# output for the sections of the manual.
# An equation in tex-math-equations.tex looks like this:
#
#    \special{dvi2bitmap outputfile equations/filename.gif} 
#             \[
#             \psi({\bf x}) = \sum_i N_i({\bf x}) \psi({\bf x}_i)
#             \]
#           \newpage
#
# or
#    \special{dvi2bitmap outputfile equations/1.5.2-eq-1.gif} 
# 	      \begin{align*}
# 	        x_\mathrm{new} &= x_\mathrm{old} + \delta x \\
# 	        y_\mathrm{new} &= y_\mathrm{old} + \delta y. \\
# 	        \end{align*}
# 	      \newpage 
#
#
# An equation in tex-math-inlines.tex looks like this:
#
#    \special{dvi2bitmap outputfile equations/filename.gif} 
#    \noindent\special{dvi2bitmap mark}
#    \(f(x_i)\)\newpage 
#
# where "filename.gif" is a unique file name for each equation.  There
# may be line feeds within the tex fragments.  The \newpage may be on
# its own line.
#
# The old process involved running latex on the tex files and
# dvi2bitmap on the resulting dvi files, which produced gifs that were
# included in the html like this:

# <div class="equation">
#   <table border="0" width="100%" summary="equation">
#     <tr>
#       <td align="center"><span class="inlinemediaobject"><img src="equations/2.4.2.2-eq-1.gif" alt="&#xA;            \[E = \alpha E_\mathrm{homog.} + (1-\alpha)E_\mathrm{shape} \]&#xA;          "></span></td>
#       <td align="left" width="8%"><a name="d0e3060"></a>(2.1)
#       </td>
#     </tr>
#   </table>
# </div>
#
# for a displayed equation and
#
# <span class="inlinemediaobject"><img src="equations/2.4.2.2-inl-3.gif" alt="\(E_\mathrm{shape}\)"></span>
#
# for an inline equation.
#
# The "right" way to convert this to MathML would be to modify
# latex-math.xsl (and maybe docbook too) so that it would pipe the tex
# from the docbook <alt> tags through latexmlmath and insert the
# result into the html output instead of creating <img> tags.  But
# doing that requires learning how docbook and latex-math.xsl work.
# So instead this script reads tex-math-equations.tex and
# tex-math-inlines.tex, extracts the equations, pipes them through
# latexmlmath to generate MathML, and replaces the <img> tags in the
# html files with it.

## TODO: compile the regexps

## Displayed equations that mistakenly use \(...\) or inline equations
## that mistakenly use \[...\] or equations of either kind that are
## missing their delimiters cause odd errors. read_equations or
## read_inlines will omit the *next* equation.  This script will fail
## with a KeyError in when looking for an equation in mathdict.
## Search tex-math-equations.tex or tex-math-inlines.tex for the
## missing key.  The equation with the incorrect delimiters will be
## the previous one in the tex file.  Maybe.  TODO: Detect incorrect
## delimiters somehow?


import getopt
import html.parser
import os
import re
import shutil
import subprocess
import sys

# When debugging, set nmax to a small integer to limit the number of
# equations parsed.
nmax = None
debug = False


def get_gifname(line):
    # Look for the "special" line that starts the equation block in
    # the tex file and extract the gif file name.
    mtch = re.search(r"\\special{dvi2bitmap outputfile (.*?)}", line)
    if mtch:
        return mtch.group(1)

def read_equations(eqnfilename, nmax=None):
    print(f"Scanning {eqnfilename}", file=sys.stderr)
    f = open(eqnfilename, "r")
    currenteqn = None
    gifname = None
    endregexp = None
    # filenamedict stores the tex input, keyed by the gif file name
    # assigned by docbook.  This name identifies the equation in the tex
    # file and where it goes in the html file.
    filenamedict = {}
    for lineno, line in enumerate(f):
        if gifname is None:
            if nmax and len(filenamedict) > nmax:
                return filenamedict
            gifname = get_gifname(line)
            # Go on to the next line of input.  This assumes that
            # there is no tex after the "\special{...}" in the
            # current line.
        elif currenteqn is None:
            # The "\special" with the file name has been found, but
            # not the start of the equation.  First look for an entire
            # equation on one line, delimited with "\[" and "\]".
            mtch = re.search(r"(\\\[.*\\\])", line)
            if mtch:
                filenamedict[gifname] = mtch.group(1)
                gifname = None  # Done with this equation
                endregexp = None
                continue # Go to next line
            # Look for the "\[" that starts the equation.
            mtch = re.search(r"(\\\[.*)", line) 
            if mtch:
                currenteqn = mtch.group(1) + "\n" # "\[" and everything after it
                endregexp = r"(.*?\\\])" # regexp matching the end "\]"
                continue                 # go to next input line
            
            # Look for "\begin{align}" or "\begin{align*}.  The regexp
            # creates a group that includes the \begin{align}.
            mtch = re.search(r"(\\begin\{align\*?\}.*)", line)
            if mtch:
                currenteqn = mtch.group(1)
                endregexp = r"(.*?\\end{align\*?\})"
        else:
            # currenteqn is not None.  Does it end on this line?
            mtch = re.search(endregexp, line)
            if mtch:
                currenteqn += mtch.group(1)
                filenamedict[gifname] = currenteqn
                currenteqn = None
                gifname = None
                endregexp = None
            else:
                # Equation doesn't end on this line
                currenteqn += line 
    f.close()
    return filenamedict


def read_inlines(eqnfilename, nmax=None):
    print(f"Scanning {eqnfilename}", file=sys.stderr)
    f = open(eqnfilename, "r")
    currenteqn = None
    gifname = None
    filenamedict = {}
    for lineno, line, in enumerate(f):
        #print(line, file=sys.stderr, end="")
        if gifname is None:
            if nmax and len(filenamedict) > nmax:
                return filenamedict
            # get_gifname() looks for a \special containing a file
            # name and returns the file name, or None if it doesn't
            # find one.
            gifname = get_gifname(line)
        elif currenteqn is None:
            # Look for "\(" and "\)" on the same line
            mtch = re.search(r"(\\\(.*\\\))", line)
            if mtch:
                filenamedict[gifname] = mtch.group(1)
                gifname = None
                endregexp = None
                continue
            # Look for "\(" without "\)" on the same line
            mtch = re.search(r"(\\\(.*)", line)
            if mtch:
                currenteqn = mtch.group(1) + "\n" # "\(" and everything after it
                continue
        else:
            # currenteqn is not None.
            mtch = re.search(r"(.*?\\\))", line)
            if mtch:
                currenteqn += mtch.group(1)
                filenamedict[gifname] = currenteqn
                currenteqn = None
                gifname = None
            else:
                currenteqn += line 
    f.close()
    return filenamedict

#=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=#

def make_texstring(eqndict):
    # Construct a tex string containing each equation in a separate
    # section, so that they can all be passed to latexmlc at once.
    texstrings = [f"\\section{{{name}}}\n{texstr}"
                  for name, texstr in eqndict.items()]
    return "\n".join(texstrings)

def make_mathml(texstring):
    process = subprocess.run(
        ["latexmlc",
         "--preload=amsmath",
         "--pmml",
         "--profile=fragment",
         "--noindex",
         "--format=html5",
         "-"],
        input=texstring,
        capture_output=True,
        text=True)
    if process.returncode:
        print("latexmlc failed with return code {process.stderr}",
              file=sys.stderr)
        print(process.stderr, file=sys.stderr)
        sys.exit(process.returncode)
    return process.stdout

#=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=#

# Class for html parsers that extract the bits of html we need from
# the latexmlc output.  The targettag argument gives the tag that the
# parser is looking for.

class MathMLExtractor(html.parser.HTMLParser):
    def __init__(self, targettag, mathdict):
        self.targettag = targettag
        self._tagDepth = {}
        self.mathdict = mathdict
        self.eqnName = None
        self.lines = []
        super().__init__()
    def feed(self, data):
        self.lines = data.split('\n')
        super().feed(data)
    def tagDepth(self, tag):
        return self._tagDepth.get(tag, 0)
    def handle_starttag(self, tag, attrs):
        self._tagDepth[tag] = self._tagDepth.get(tag, 0) + 1
        if tag == self.targettag and self.tagDepth(self.targettag) == 1:
            self.startline, self.startoffset = self.getpos() # (lineno, offset)
            self.startline -= 1
    def handle_endtag(self, tag):
        self._tagDepth[tag] -= 1
        if tag == self.targettag and self.tagDepth(self.targettag) == 0:
            endline, endoffset = self.getpos()
            endline -= 1
            if endline == self.startline:
                htmllines = [
                    self.lines[endline][self.startoffset:endoffset]]
            else:
                # The first line of html starts on the startline, but
                # might not include the whole line.
                htmllines = [self.lines[self.startline][self.startoffset:]]
                # Include the complete lines.
                for lineno in range(self.startline+1, endline):
                    htmllines.append(self.lines[lineno])
                # Include the final line, which might also be partial.
                htmllines.append(self.lines[endline][:endoffset])
            # The end offset is before the closing tag, so include it
            # manually.
            htmllines.append(f"</{tag}>")
            self.mathdict[self.eqnName] = " ".join(htmllines)
            
            self.eqnName = None
    def handle_data(self, data):
        # The equation's gif file name is in html that looks like
        # <h2 class="..."><span class="..."> ... </span> filename</h2>
        # So the data we want is what's in the <h2> but not the <span>.
        ## TODO: This could break badly if using a newer (or older)
        ## version of LaTeXML.  Is there a better way?
        if self.tagDepth("span") == 0 and self.tagDepth("h2") == 1:
            self.eqnName = data

#=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=#

# The html created by docbook contains display equations that look
# like this:
#
# <div class="equation">
#    <table border="0" width="100%" summary="equation">
#       <tr>
#          <td align="center"><span class="inlinemediaobject"><img src="equations/2.5.1-eq-1.gif" alt="&#xA;          \[(tex source) \]&#xA;        "></span></td>
#          <td align="left" width="8%"><a name="d0e3641"></a>(2.4)
#          </td>
#       </tr>
#    </table>
# </div>
#
#  Inline equations that look like this:
#
# <span class="inlinemediaobject"><img src="equations/2.5.1-inl-4.gif" alt="\(r\)"></span>
#
# In both cases, we want to replace
#     <img src="filename" alt="...">
# with the MathML from the mathdict[filename].
#
# <img> tags also occur in figures and the page navigation buttons.
# <img> always have "src" attributes, which we can use to distinguish
# equations from other images.

## TODO: Where is the directory name "equations" set?

# ImageReplacerHTML expects html, not xhtml, with UNclosed <img> tags.

class ImageReplacerHTML(html.parser.HTMLParser):
    def __init__(self, filename, mathdict):
        self.filename = filename
        self.mathdict = mathdict
        super().__init__()
        self.lastline = None
        # "awfset" is the offset that converts indices as returned by
        # HTMLParser.getpos() to indices in the lines saved in
        # self.lines.  Once one substitution is made in self.lines,
        # the positions of the remaining tags need to be adjusted.
        # The variable "offset" is already used by HTMLParser, so it
        # needs to be spelled wrong here.
        self.awfset = 0
    def feed(self, data):
        self.lines = data.split('\n')
        super().feed(data)
    def handle_starttag(self, tag, attrs):
        if tag == "img":
            # See if this <img>'s "src" attribute is an equation gif.
            gifname = None
            for attr, val in attrs:
                if attr == "src":
                    gifname = val
                    break
            if gifname == None or not gifname.startswith("equations/"):
                # Not our tag
                return
            replacement = self.mathdict[gifname]
            lineno, startpos = self.getpos()
            lineno -= 1         # HTMLParser starts at line 1, not line 0
            line = self.lines[lineno]
            # There can be more than one <img> tag on a line.  The
            # startpos for tags after the first will need to be
            # adjusted.  getpos() returns indices into the original
            # unmodified line, but self.lines contains the modified
            # line.
            if lineno == self.lastline:
                # Still in the old line
                # Convert position in original line to position in
                # modified line.
                startpos += self.awfset
            else:
                # Starting a new line.
                self.awfset = 0
            # Find the end of the <img> tag.  The tag isn't closed
            # with "/> or "</img>", so just look for ">".  Assume that
            # it's on the same line, since that seems to be where
            # docbook always puts it.
            #
            # If we use docbook in xhtml mode, it creates correctly
            # closed <img> tags, and we could use
            # HTMLParser.handle_startendtag() instead of searching for
            # the end ">" manually.  This would presumably be more
            # robust, in case any attributes in the <img> contained
            # ">".  But xhtml mode produces terrible output for class
            # synopses and program listings, so we're sticking with
            # html for now.
            endpos = line.find(">", startpos)
            assert endpos != -1
            endpos += 1         # one past the closing >
            replaced = line[startpos:endpos]
            replacement = self.mathdict[gifname]
            self.lines[lineno] = (line[:startpos] + replacement + line[endpos:])
            # Prepare for more <img> tags in this line
            self.awfset += len(replacement) - len(replaced)
            self.lastline = lineno


def process_html(dirname, mathdict):
    for htmlfilename in os.listdir(dirname):
        basename, suffix = os.path.splitext(htmlfilename)
        if suffix == ".html":
            print(f"======= Processing {htmlfilename}", file=sys.stderr)
            # Make a backup copy of the original file
            shutil.copy(os.path.join(dirname, htmlfilename),
                        os.path.join(dirname, htmlfilename+".bak"))
            
            htmlfile = open(os.path.join(dirname, htmlfilename), mode="r")
            htmltext = htmlfile.read()
            htmlfile.close()
            parser = ImageReplacerHTML(basename, mathdict)
            parser.feed(htmltext)
            parser.close()

            resultfile = open(os.path.join(dirname, htmlfilename), mode="w")
            for line in parser.lines:
                print(line, file=resultfile)
            resultfile.close()
    
def do_undo(dirname):
    for htmlfilename in os.listdir(dirname):
        basename, suffix = os.path.splitext(htmlfilename)
        if suffix == ".bak":
            os.rename(os.path.join(dirname,htmlfilename),
                      os.path.join(dirname, basename))

#=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=#

def do_conversion(tmpdirname, eqnfilename, inlinefilename):

    eqndict = read_equations(os.path.join(tmpdirname, eqnfilename),
                             nmax=nmax)
    inlinedict = read_inlines(os.path.join(tmpdirname, inlinefilename),
                              nmax=nmax)

    eqntex = make_texstring(eqndict)
    inlinetex = make_texstring(inlinedict)

    if debug:
        print("Dumping tex to eqndump.tex", file=sys.stderr)
        dump = open("eqndump.tex", "w")
        print(eqntex, file=dump)
        print("% -------", file=dump)
        print(inlinetex, file=dump)
        dump.close()
    
    # Convert to MathML
    print("Running latexmlc for display equations", file=sys.stderr)
    eqnmathml = make_mathml(eqntex)
    print("Running latexmlc for inline equations", file=sys.stderr)    
    inlinemathml = make_mathml(inlinetex)
    
    if debug:
        print("Dumping html to eqndump.html", file=sys.stderr)
        dump = open("eqndump.html", "w")
        print(eqnmathml, file=dump)
        print("% ------", file=dump)
        print(inlinemathml, file=dump)
        dump.close()

    # Extract MathML from the latexmlc output.  Each equation is
    # inside a <table> inside a <div> that begins with an <h2> title
    # given by the gif file name.

    mathdict = {}
    
    parser = MathMLExtractor("table", mathdict)
    parser.feed(eqnmathml)
    parser.close()

    parser = MathMLExtractor("math", mathdict)
    parser.feed(inlinemathml)
    parser.close()

    if debug:
        print("Dumping MathML to mathml.html", file=sys.stderr)
        dump = open("mathml.html", "w")
        for name, math in mathdict.items():
            print(f"{name}: {math}\n", file=dump)
        dump.close()
    
    print("Rewriting html files", file=sys.stderr)
    process_html(tmpdirname, mathdict)

#=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=#

def usage():
    print(
"""Usage:
python converteqns.py [options]
   Options:
   --tempdir=directory    Directory containing saxon output 
   --equations=file       The tex file in tempdir containing equations
   --inlines=file         The tex file in tempdir containing inline equations
   --undo                 Restore from backup files without processing
   --help                 Print this

--tempdir is always required.  --equations and --inlines are required
unless --undo is given.
   """)

#=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=##=--=#

if __name__ == "__main__":

    options = ['tempdir=', 'equations=', 'inlines=', "undo", "help"]
    try:
        (optlist, args) = getopt.getopt(sys.argv[1:], "", options)
    except getopt.error as message:
        print(message)
        sys.exit(1)

    tmpdirname = None
    eqnfilename = None
    inlinefilename = None
    undo = False

    for opt, val in optlist:
        if opt == '--tempdir':
            tmpdirname = val
        elif opt == '--equations':
            eqnfilename = val
        elif opt == '--inlines':
            inlinefilename = val
        elif opt == '--undo':
            undo = True
        elif opt == '--help':
            usage()
            sys.exit(0)
        else:
            assert False, "Unknown option"

    if tmpdirname is None:
        usage()
        sys.exit(0)
    if not undo and (eqnfilename is None or inlinefilename is None):
        usage()
        sys.exit(0)

    if not undo:
        do_conversion(tmpdirname, eqnfilename, inlinefilename)
    else:
        do_undo(tmpdirname)

