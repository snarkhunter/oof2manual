# Makefile for creating readable docs from the xml files.  For this to
# work, the current directory needs to have a symbolic link called
# 'bin' that points to the directory where the executable lives and a
# link called 'build' pointing to the OOF2 build directory.

# The following variables must be set in this file:

# WEB_DIR is the base of the *local* web server file system.  For
# example, on macOS it could be ~/Sites.  If you don't have a local
# server, set WEB_DIR to any empty writable directory outside of
# TEMP_DIR.
WEB_DIR = /Users/langer/Sites

# WEB_SUBDIR is the subdirectory of WEB_DIR that will contain the html
# files.  It is also used as a temporary directory when building the
# manual, as the name of the staging subdirectory in OOFSTOWDIR when
# building OOF2, and as the filename of the distribution (if a
# distribution is being built),
WEB_SUBDIR = oof2man

# variable names begining with OOF control how to build and run OOF2
# in order to generate the reference pages.

# OOF_BUILD_DIR is the build directory containing the Makefile generated
# by cmake.  
OOF_BUILD_DIR = /Users/langer/FE/OOF2/build-py311

# OOF_STOW_DIR is the directory containing the subdirectory where
# OOF2 will be staged during installation.
OOF_STOW_DIR = /Users/langer/stow

# OOF_DEST_DIR is the subdirectory of OOF_STOW_DIR that will be used as
# the staging directory.  Setting it to WEB_SUBDIR guarantees that it
# won't overwrite another staged installation.
OOF_DEST_DIR = $(WEB_SUBDIR)
#OOF_DEST_DIR = oof2-py311

# OOF_STOW_SUBDIR is the subdirectory of OOF_STOW_DIR where OOF2 will be
# staged during installation.  It is the intermediate destination
# (DESTDIR) of the build. 
OOF_STOW_SUBDIR = $(OOF_STOW_DIR)/$(OOF_DEST_DIR)

# OOFBINDIR is where the top oof2 executable can be found after it's
# installed.
OOFBINDIR = /Users/langer/bin

# TEMP_DIR is the name of a temporary directory that will be created in
# this directory.
TEMP_DIR = tmpdir

# To generate the manual by a different version of OOF2
# without overwriting an existing manual, at a minimum you must
# change OOF_BUILD_DIR to point to the different OOF2 directory and
# change WEB_SUBDIR to point to a different installation directory.

# All xml files that are *not* part of the reference section generated
# by OOF2's xmlmenudump need to be listed in the file xmlfilelist in
# this directory.  The list needs to be in the order in which the
# files are included in the main document.  This ordering is used in
# the "See Also" sections of the reference pages.  If it's wrong, some
# pages will be less pretty.

# "make local" generates html from the xml source files, using the xml
# tools, and then wraps the html output in NIST boilerplate and puts
# it in WEB_DIR/WEB_SUBDIR.

# "make publish" copies the local output to the CTCMS web server.



# There's no need to explicitly list all of the xml files in the
# dependencies.  They're included by man_oof2.xml, which depends on
# oof2_api.xml, and oof2_api.ml is always rebuilt.

SAXON = ../xsl/java/saxon.jar
## TODO: More up-to-date saxon from MacPorts raises lots of warnings
## and errors.  Is there any point in updating?
#SAXON = /opt/local/share/java/saxon9he.jar

local: $(TEMP_DIR) saxonize.web texify_mathml figs 
	python webwrap.py --from=$(TEMP_DIR) --to=$(WEB_DIR)/$(WEB_SUBDIR) --styledir=STYLE --exclude=.tex,.dvi,.aux,.log,.bak
	touch local

# TODO: Install into /u/WWW/langer/oof/oof2man, so that
# http://www.ctcms.nist.gov/oof/oof2man links (without reference to
# ~langer).  Check links everywhere.

publish: local
	rsync -vrt --delete-excluded -e ssh --rsync-path=/usr/bin/rsync $(WEB_DIR)/$(WEB_SUBDIR)/* genie.nist.gov:/u/WWW/langer/$(WEB_SUBDIR)
	ssh genie.nist.gov /usr/site/bin/updatewww
	touch publish

publish-draft: local
	rsync -vrt --delete-excluded -e ssh --rsync-path=/usr/bin/rsync $(WEB_DIR)/$(WEB_SUBDIR)/* genie.nist.gov:/u/WWW/langer/$(WEB_SUBDIR)-draft
	ssh genie.nist.gov /usr/site/bin/updatewww
	touch publish-draft

# Build the file that users can download to create a local copy of
# the manual.  
oof2man.tgz: $(TEMP_DIR) saxonize.ext texify_mathml figs 
	-mkdir $(WEB_SUBDIR)
	python webwrap.py --from=$(TEMP_DIR) --to=$(WEB_SUBDIR) --styledir=STYLE --exclude=.tex,.dvi,.aux,.log
	tar -czf $(WEB_SUBDIR).tgz $(WEB_SUBDIR)
	-rm -rf $(WEB_SUBDIR)

saxonize.web: oof2_api.xml
	mkdir $(TEMP_DIR)/equations
	(cd $(TEMP_DIR); rm -f *.html; java -jar $(SAXON) ../man_oof2.xml ../xsl/oofchunk.xsl nist.exit.script=1)

saxonize.ext: oof2_api.xml
	(cd $(TEMP_DIR); rm -f *.html; java -jar $(SAXON) ../man_oof2.xml ../xsl/oofchunk.xsl)


texify_mathml: saxonize.web
	python converteqns.py --tempdir=$(TEMP_DIR) --equations=tex-math-equations.tex --inlines=tex-math-inlines.tex

# # -------------------
# # Obsolete version using dvi2bitmap instead of mathml for equations.
# # Not deleted yet because mathml isn't working perfectly either.  To
# # switch back, uncomment this block and change texify_mathml to
# # texify in the rules for oof2man.tgz and local.
# # 
# # On macOS with macports, dvi2bitmap needs to be built with
# # --with-kpathsea --enable-fontgen
# #
# DVI2BITMAP = dvi2bitmap --magnification=5 --scaledown=4 --output-type=gif --font-search=kpathsea
# texify:
# 	(cd $(TEMP_DIR); latex tex-math-inlines.tex && $(DVI2BITMAP) --verbose=quiet --query=bitmaps tex-math-inlines | awk '{printf "img[src=\"%s\"] {margin-bottom:%dpx;}\n",$$2,$$6-$$4}' > inline.css)
# 	(cd $(TEMP_DIR); latex tex-math-equations.tex && $(DVI2BITMAP) tex-math-equations)


oof2: always
	(cd $(OOF_BUILD_DIR); make -j 10 DESTDIR=$(OOF_STOW_SUBDIR) install; cd $(OOF_STOW_DIR); ./switchto $(OOF_DEST_DIR))

oof2_api.xml: oof2 xmlfilelist
	$(OOFBINDIR)/oof2 --autoload --script xmldump.py --quiet --debug
	sed s/Graphics_1/Graphics_n/g oof2_api.xml > tmp
	sed s/Messages_1/Messages_n/g tmp > oof2_api.xml
	-rm -f tmp

$(TEMP_DIR): always
	-rm -rf $(TEMP_DIR)
	mkdir $(TEMP_DIR)
	ln -s ../STYLE $(TEMP_DIR)/STYLE

figs: $(TEMP_DIR)
	-mkdir $(TEMP_DIR)/FIGURES
	-mkdir $(TEMP_DIR)/IMAGES
	rsync -r -C --delete --delete-excluded --exclude "*.eps" --exclude "*.graffle" FIGURES $(TEMP_DIR)/
	rsync -r -C --delete --delete-excluded --exclude "*.eps" --exclude "*.graffle" IMAGES $(TEMP_DIR)/

always:

# The "equations" target is used when it's necessary to re-run latex
# by hand.  This is useful when debugging the equation formatting by
# editing tex-math-*.tex.  Remember that changes in tex-math-*.tex are
# not permanent.  They'll be overwritten the next time saxon is run.
## TODO: Rewrite this for latexml.
equations:
	(cd $(TEMP_DIR); latex tex-math-inlines.tex && $(DVI2BITMAP) --verbose=quiet --query=bitmaps tex-math-inlines | awk '{printf "img[src=\"%s\"] {margin-bottom:%dpx;}\n",$$2,$$6-$$4}' > inline.css)
	(cd $(TEMP_DIR); latex tex-math-equations.tex && $(DVI2BITMAP) tex-math-equations)
	python webwrap.py --from=$(TEMP_DIR) --to=$(WEB_DIR)/$(WEB_SUBDIR) --styledir=STYLE --exclude=.tex,.dvi,.aux,.log

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
