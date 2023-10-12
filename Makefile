#  $RCSfile: Makefile,v $
#  $Revision: 1.9 $
#  $Author: langer $
#  $Date: 2011-05-06 17:48:15 $

# Makefile for creating readable docs from the xml files.  For this to
# work, the current directory needs to have a symbolic link called
# 'bin' that points to the directory where the executable lives and a
# link called 'build' pointing to the OOF2 build directory.  The
# environment variable OOFWEBDIR should be set to the base of the
# *local* web server file system.  For example, on OS X it should be
# set to ~/Sites.  If you don't have a local server, set OOFWEBDIR to
# any empty writable directory outside of tmpdir.

# "make local" generates html from the xml source files, using the xml
# tools, and then wraps the html output in NIST boilerplate and puts
# it in OOFWEBDIR/oof2man.

# "make publish" copies the local output to the CTCMS web server.

XMLFILES = CH_graphics.xml CH_tasks.xml CH_windows.xml SN_skel.xml     \
man_oof2.xml oof2_api.xml CH_overview.xml CH_concepts.xml SN_micro.xml

# On macOS with macports, dvi2bitmap needs to be built with
# --with-kpathsea --enable-fontgen

DVI2BITMAP = dvi2bitmap --magnification=5 --scaledown=4 --output-type=gif --font-search=kpathsea

# TEMPDIR used to be called "TMPDIR", but that conflicts with the
# TMPDIR environment variable that dvi2bitmap uses to communicate with
# mktexpk if it's not using kpathsea. 
TEMPDIR = tmpdir

# # Build the version that we put on our web site.  This has to be
# # manually copied over.
# publish: $(TEMPDIR) saxonize.web texify figs
# 	-mkdir html
# 	rm -rf html/*
# 	python2 webwrap.py --from=$(TEMPDIR) --to=html --styledir=STYLE --exclude=.tex,.dvi,.aux,.log
# 	touch publish

local: $(TEMPDIR) saxonize.web texify figs 
	python webwrap.py --from=$(TEMPDIR) --to=$(OOFWEBDIR)/oof2man --styledir=STYLE --exclude=.tex,.dvi,.aux,.log
	touch local

publish: local
	rsync -vrt --delete-excluded -e ssh --rsync-path=/usr/bin/rsync $(OOFWEBDIR)/oof2man/* genie.nist.gov:/u/WWW/langer/oof2man
	ssh genie.nist.gov /usr/site/bin/updatewww
	touch publish

# Build the file that users can download to create a local copy of
# the manual.  
oof2man.tgz: $(TEMPDIR) saxonize.ext texify figs 
	-mkdir oof2man
	python webwrap.py --from=$(TEMPDIR) --to=oof2man --styledir=STYLE --exclude=.tex,.dvi,.aux,.log
	tar -czf oof2man.tgz oof2man
	-rm -rf oof2man

saxonize.web: $(XMLFILES)
	mkdir $(TEMPDIR)/equations
	(cd $(TEMPDIR); rm -f *.html; java -jar ../xsl/java/saxon.jar ../man_oof2.xml ../xsl/oofchunk.xsl nist.exit.script=1)

saxonize.ext: $(XMLFILES)
	(cd $(TEMPDIR); rm -f *.html; java -jar ../xsl/java/saxon.jar ../man_oof2.xml ../xsl/oofchunk.xsl)

texify:
	(cd $(TEMPDIR); latex tex-math-inlines.tex && $(DVI2BITMAP) --verbose=quiet --query=bitmaps tex-math-inlines | awk '{printf "img[src=\"%s\"] {margin-bottom:%dpx;}\n",$$2,$$6-$$4}' > inline.css)
	(cd $(TEMPDIR); latex tex-math-equations.tex && $(DVI2BITMAP) tex-math-equations)

oof2_api.xml: always
	(cd build; make -j 10 DESTDIR=~/stow/oof2-manual install; cd ~/stow; ./switchto oof2-manual)
	bin/oof2 --script xmldump.py --batch --debug
	sed s/Graphics_1/Graphics_n/g oof2_api.xml > tmp
	mv -f tmp oof2_api.xml

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
	java -jar /sw/share/java/saxon/saxon.jar -o test2.html test.xml /sw/share/xml/xsl/docbook-xsl/html/docbook.xsl

sandbox.html: sandbox.xml oof2.css
	-mkdir sandbox
	(cd sandbox; rm -f *.html; java -jar ../xsl/java/saxon.jar ../sandbox.xml ../xsl/oofchunk.xsl)
	cp -f oof2.css sandbox
	cp -f templates/*.html sandbox
	/Library/WebServer/Documents/CSS/ctcmsWeb.py --from=sandbox --to=/Users/langer/Sites/sandbox --machine=localhost
	touch sandbox.html

sandboxtex.html: sandboxtex.xml oof2.css
	-mkdir sandboxtex
	(cd sandboxtex; rm -f *.html; java -jar ../xsl/java/saxon.jar ../sandboxtex.xml ../xsl/oofchunk.xsl)
	(cd sandboxtex; latex tex-math-inlines.tex && $(DVI2BITMAP) --verbose=quiet --query=bitmaps tex-math-inlines | awk '{printf "img[src=\"%s\"] {margin-bottom:%dpx;}\n",$$2,$$6-$$4}' > inline.css)
	(cd sandboxtex; latex tex-math-equations.tex && $(DVI2BITMAP) tex-math-equations)
	#cp -f oof2.css sandboxtex
	#cp -f templates/*.html sandboxtex
	#/Library/WebServer/Documents/CSS/ctcmsWeb.py --from=sandboxtex --to=/Users/langer/Sites/sandboxtex --machine=localhost --exclude=.tex,.dvi,.log,.aux
	touch sandboxtex.html
