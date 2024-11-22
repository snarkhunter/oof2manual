# Makefile for creating readable docs from the xml files.  For this to
# work, the current directory needs to have a symbolic link called
# 'bin' that points to the directory where the executable lives and a
# link called 'build' pointing to the OOF2 build directory.  The
# environment variable OOFWEBDIR should be set to the base of the
# *local* web server file system.  For example, on OS X it should be
# set to ~/Sites.  If you don't have a local server, set OOFWEBDIR to
# any empty writable directory outside of tmpdir.

# All xml files that are *not* part of the reference section generated
# by OOF2's xmlmenudump need to be listed in the file xmlfilelist in
# this directory.  The list needs to be in the order in which the
# files are included in the main document.  This ordering is used in
# the "See Also" sections of the reference pages.  If it's wrong, some
# pages will be less pretty.

# "make local" generates html from the xml source files, using the xml
# tools, and then wraps the html output in NIST boilerplate and puts
# it in OOFWEBDIR/oof2man.

# "make publish" copies the local output to the CTCMS web server.

# On macOS with macports, dvi2bitmap needs to be built with
# --with-kpathsea --enable-fontgen

DVI2BITMAP = dvi2bitmap --magnification=5 --scaledown=4 --output-type=gif --font-search=kpathsea

TEMPDIR = tmpdir

# There's no need to explicitly list all of the xml files in the
# dependencies.  They're included by man_oof2.xml, which depends on
# oof2_api.xml, and oof2_api.ml is always rebuilt.

SAXON = ../xsl/java/saxon.jar
## TODO: More up-to-date saxon from MacPorts raises lots of warnings
## and errors.  Is there any point in updating?
#SAXON = /opt/local/share/java/saxon9he.jar

local: $(TEMPDIR) saxonize.web texify_mathml figs 
	python webwrap.py --from=$(TEMPDIR) --to=$(OOFWEBDIR)/oof2man --styledir=STYLE --exclude=.tex,.dvi,.aux,.log,.bak
	touch local

# TODO: Install into /u/WWW/langer/oof/oof2man, so that
# http://www.ctcms.nist.gov/oof/oof2man links (without reference to
# ~langer).  Check links everywhere.

publish: local
	rsync -vrt --delete-excluded -e ssh --rsync-path=/usr/bin/rsync $(OOFWEBDIR)/oof2man/* genie.nist.gov:/u/WWW/langer/oof2man
	ssh genie.nist.gov /usr/site/bin/updatewww
	touch publish

publish-draft: local
	rsync -vrt --delete-excluded -e ssh --rsync-path=/usr/bin/rsync $(OOFWEBDIR)/oof2man/* genie.nist.gov:/u/WWW/langer/oof2man-draft
	ssh genie.nist.gov /usr/site/bin/updatewww
	touch publish-draft

# Build the file that users can download to create a local copy of
# the manual.  
oof2man.tgz: $(TEMPDIR) saxonize.ext texify_mathml figs 
	-mkdir oof2man
	python webwrap.py --from=$(TEMPDIR) --to=oof2man --styledir=STYLE --exclude=.tex,.dvi,.aux,.log
	tar -czf oof2man.tgz oof2man
	-rm -rf oof2man

saxonize.web: oof2_api.xml
	mkdir $(TEMPDIR)/equations
	(cd $(TEMPDIR); rm -f *.html; java -jar $(SAXON) ../man_oof2.xml ../xsl/oofchunk.xsl nist.exit.script=1)

saxonize.ext: oof2_api.xml
	(cd $(TEMPDIR); rm -f *.html; java -jar $(SAXON) ../man_oof2.xml ../xsl/oofchunk.xsl)

texify:
	(cd $(TEMPDIR); latex tex-math-inlines.tex && $(DVI2BITMAP) --verbose=quiet --query=bitmaps tex-math-inlines | awk '{printf "img[src=\"%s\"] {margin-bottom:%dpx;}\n",$$2,$$6-$$4}' > inline.css)
	(cd $(TEMPDIR); latex tex-math-equations.tex && $(DVI2BITMAP) tex-math-equations)

texify_mathml: saxonize.web
	python converteqns.py --tempdir=$(TEMPDIR) --equations=tex-math-equations.tex --inlines=tex-math-inlines.tex 

oof2: always
	(cd build; make -j 10 DESTDIR=~/stow/oof2-py311 install; cd ~/stow; ./switchto oof2-py311)

oof2_api.xml: oof2 xmlfilelist
	bin/oof2 --autoload --script xmldump.py --quiet --debug
	sed s/Graphics_1/Graphics_n/g oof2_api.xml > tmp
	sed s/Messages_1/Messages_n/g tmp > oof2_api.xml
	-rm -f tmp

$(TEMPDIR): always
	-rm -rf $(TEMPDIR)
	mkdir $(TEMPDIR)
	ln -s ../STYLE $(TEMPDIR)/STYLE

figs: $(TEMPDIR)
	-mkdir $(TEMPDIR)/FIGURES
	-mkdir $(TEMPDIR)/IMAGES
	rsync -r -C --delete --delete-excluded --exclude "*.eps" --exclude "*.graffle" FIGURES $(TEMPDIR)/
	rsync -r -C --delete --delete-excluded --exclude "*.eps" --exclude "*.graffle" IMAGES $(TEMPDIR)/

always:

# The "equations" target is used when it's necessary to re-run latex
# by hand.  This is useful when debugging the equation formatting by
# editing tex-math-*.tex.  Remember that changes in tex-math-*.tex are
# not permanent.  They'll be overwritten the next time saxon is run.
## TODO: Rewrite this for latexml.
equations:
	(cd $(TEMPDIR); latex tex-math-inlines.tex && $(DVI2BITMAP) --verbose=quiet --query=bitmaps tex-math-inlines | awk '{printf "img[src=\"%s\"] {margin-bottom:%dpx;}\n",$$2,$$6-$$4}' > inline.css)
	(cd $(TEMPDIR); latex tex-math-equations.tex && $(DVI2BITMAP) tex-math-equations)
	python webwrap.py --from=$(TEMPDIR) --to=$(OOFWEBDIR)/oof2man --styledir=STYLE --exclude=.tex,.dvi,.aux,.log

#pdf: $(XMLFILES)
#	#docbook2pdf -l /sw/share/sgml/dsssl/docbook-dsssl-nwalsh/dtds/decls/xml.dcl man_oof2.xml 
#	xsltproc -o man_oof2.fo --stringparam fop.extensions 1 /sw/share/xml/xsl/docbook-xsl/fo/docbook.xsl man_oof2.xml
#	fop man_oof2.fo -pdf man_oof2.pdf

#rtf: $(XMLFILES)
#	docbook2rtf -l dtd/xml.dcl man_oof2.xml 

test.html: test.xml
	docbook2html  -l dtd/xml.dcl test.xml

test2.html: test.xml
	java -jar $(SAXON) -o test2.html test.xml /sw/share/xml/xsl/docbook-xsl/html/docbook.xsl

sandbox.html: sandbox.xml oof2.css
	-mkdir sandbox
	(cd sandbox; rm -f *.html; java -jar $(SAXON) ../sandbox.xml ../xsl/oofchunk.xsl)
	cp -f oof2.css sandbox
	cp -f templates/*.html sandbox
	/Library/WebServer/Documents/CSS/ctcmsWeb.py --from=sandbox --to=/Users/langer/Sites/sandbox --machine=localhost
	touch sandbox.html

sandboxtex.html: sandboxtex.xml oof2.css
	-mkdir sandboxtex
	(cd sandboxtex; rm -f *.html; java -jar $(SAXON) ../sandboxtex.xml ../xsl/oofchunk.xsl)
	(cd sandboxtex; latex tex-math-inlines.tex && $(DVI2BITMAP) --verbose=quiet --query=bitmaps tex-math-inlines | awk '{printf "img[src=\"%s\"] {margin-bottom:%dpx;}\n",$$2,$$6-$$4}' > inline.css)
	(cd sandboxtex; latex tex-math-equations.tex && $(DVI2BITMAP) tex-math-equations)
	#cp -f oof2.css sandboxtex
	#cp -f templates/*.html sandboxtex
	#/Library/WebServer/Documents/CSS/ctcmsWeb.py --from=sandboxtex --to=/Users/langer/Sites/sandboxtex --machine=localhost --exclude=.tex,.dvi,.log,.aux
	touch sandboxtex.html
