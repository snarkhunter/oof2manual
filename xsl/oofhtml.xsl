<?xml version='1.0'?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp "&#160;">
]>

<!--
This file is included at the end of oofchunk.xsl, which is the
top stylesheet.  oofchunk.xsl *imports* html/docbook.xsl but
and html/chunk-common.xsl but *includes* html/chunk-code.xsl.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="docbook-xsl-4.5/html/docbook.xsl"/>
  <xsl:import href="latex-math/xsl/latex-math.xsl"/>

  <!-- Customized templates -->
  <xsl:include href="pysynop.xsl"/> <!-- python reference page synopsis -->
  <xsl:include href="nistexit.xsl"/> <!-- redirect external URLs -->
  <xsl:include href="fonts.xsl"/>    <!-- typography twiddling -->

  <!-- modification to generate.toc so that lists of equations and figures are
       *not* generated.  To restore figures, add 'figure' to the 'book' line -->
  <xsl:param name="generate.toc">
    appendix  toc,title
    article/appendix  nop
    article   toc,title
    book      toc,title
    chapter   toc,title
    part      toc,title
    preface   toc,title
    qandadiv  toc
    qandaset  toc
    reference toc,title
    sect1     toc
    sect2     toc
    sect3     toc
    sect4     toc
    sect5     toc
    section   toc,title
    set       toc,title
  </xsl:param>

  <!-- Keep the size of tables of contents down by limiting their depth. -->
  <xsl:param name="toc.section.depth">1</xsl:param>

  
  
  <!-- ========================== -->
  
  <!-- This is a modified version of the "section" template that
       always builds a table of contents for sections with 
       role='reference' or with an ancestor with role='reference'.
       The original is in docbotook-xsl-4.5/html/sections.xsl.

       The modification is the addition of //section[ancestor...] to
       the xsl:if test.

       Without this, sections in CH_extendingref.xml don't get a toc,
       and the refentries are only accessible through the Next and
       Prev buttons.
    
       This change on its own doesn't quite work.  The subsections
       are not put into separate chunks, but navigation buttons that
       should refer to the subsections don't know that, so they link
       to nonexistent files.

       WHERE IS CHUNKING INVOKED?  WHY DOES THIS NOT PUT REFERENCE
       SUBSECTIONS IN SEPARATE CHUNKS?
  -->
  <!-- <xsl:template match="//section[ancestor-or-self::*[@role='reference']]">
    <xsl:message>
      <xsl:text>Reference Section: </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text> starting</xsl:text>
    </xsl:message>
  
    <xsl:call-template name="id.warning"/>
  
    <div>
      <xsl:call-template name="common.html.attributes">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="section.titlepage"/>
      
      <p><xsl:value-of select="@id"/> is a reference section!</p>
      <xsl:message>
        <xsl:text>**** </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text> is a reference section</xsl:text>
      </xsl:message>
  
      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>
  
      <xsl:if test="contains($toc.params, 'toc')">
        <xsl:call-template name="section.toc">
          <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
        </xsl:call-template>
        <xsl:call-template name="section.toc.separator"/>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:call-template name="process.chunk.footnotes"/>
    </div>
    <xsl:message>
      <xsl:text>Reference Section: </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text> ending</xsl:text>
    </xsl:message>
  
  </xsl:template> -->
  
  <!-- ============================================================= -->

  <!-- This version is from gemini.google.com, not just the Gemini
       that responds to browser searches
  -->

  <!-- <xsl:template match="section" mode="toc" priority="1">
    <xsl:param name="toc-context" select="."/>
    
    <!-\- Determine depth dynamically based on the role attribute -\->
    <xsl:variable name="current-depth">
      <xsl:choose>
        <!-\- 4 is probably too much -\->
        <xsl:when test="ancestor-or-self::section[@role='reference']">2</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$toc.section.depth"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
  
    <!-\- Wrap each entry in a list item -\->
    <li>
      <xsl:call-template name="toc.line">
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
  
      <!-\- Recursively generate child entries inside a nested <ul> if depth allows -\->
      <xsl:if test="$current-depth &gt; count(ancestor::section) - count($toc-context/ancestor::section)">
        <xsl:variable name="nodes" select="section | simplesect"/>
        <xsl:if test="$nodes">
          <ul>
            <xsl:apply-templates select="$nodes" mode="toc">
              <xsl:with-param name="toc-context" select="$toc-context"/>
            </xsl:apply-templates>
          </ul>
        </xsl:if>
      </xsl:if>
    </li>
  </xsl:template> -->

  
<!-- <!-\- Customize the subtoc or section processing template in mode="toc" -\->
  <xsl:template match="section" mode="toc">
    <xsl:param name="toc-context" select="."/>
    
    <!-\- Determine depth dynamically based on the role attribute -\->
    <xsl:variable name="current-depth">
      <xsl:choose>
        <!-\- If this section (or an ancestor section) has role="reference", allow depth up to 4 -\->
        <xsl:when test="ancestor-or-self::section[@role='reference']">
          <xsl:value-of select="4"/>
        </xsl:when>
        <!-\- Otherwise fallback to the global parameter value -\->
        <xsl:otherwise>
          <xsl:value-of select="$toc.section.depth"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-\- Standard TOC line generation for the section itself -\->
    <p>
      <xsl:call-template name="toc.line">
        <xsl:with-param name="toc-context" select="$toc-context"/>
      </xsl:call-template>
    </p>
    <!-\- Recursively generate child entries only if current section depth allows -\->
    <xsl:if test="$current-depth &gt; count(ancestor::section) - count($toc-context/ancestor::section)">
      <xsl:variable name="nodes" select="section | simplesect"/>
      <xsl:if test="$nodes">
        <dl>
          <xsl:apply-templates select="$nodes" mode="toc">
            <xsl:with-param name="toc-context" select="$toc-context"/>
          </xsl:apply-templates>
        </dl>
      </xsl:if>
    </xsl:if>
  </xsl:template> -->
  

  <!-- ============================================================= -->

  <!-- This is a modified version of the "section" template that
       always builds a table of contents for sections with
       role='reference'.

       This is the one used in earlier versions of the manual
  -->
  
  <!-- <xsl:template match="section[@role='reference']">
    <xsl:variable name="depth" select="count(ancestor::section)+1"/>
    <xsl:comment>In section[@role='reference'] template</xsl:comment>
    <xsl:call-template name="id.warning"/>
  
    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>
  
    <div class="{name(.)}">
      <xsl:call-template name="dir">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="language.attribute"/>
      <xsl:call-template name="section.titlepage"/>
  
      <xsl:call-template name="section.toc">
        <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
      </xsl:call-template>
      <xsl:call-template name="section.toc.separator"/>
      
      <xsl:apply-templates/>
      <xsl:call-template name="process.chunk.footnotes"/>
    </div>
  </xsl:template> -->

  <!-- ============================================================= -->
  
  <!-- This version is from Gemini -->
  <!-- <xsl:template match="section[@role='reference']" mode="toc">
    <xsl:param name="toc-context" select="."/>
    
    <xsl:call-template name="toc.line">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  
    <xsl:variable name="nodes" select="section | refentry | apiref | simplesect"/>
    
    <xsl:if test="$nodes">
      <dl>
        <xsl:apply-templates mode="toc" select="$nodes">
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:apply-templates>
      </dl>
      <xsl:call-template name="section.toc.separator"/>
    </xsl:if>
  </xsl:template> -->

  <!-- ============================================================= -->
  
  <!-- <!-\- Modified the Gemini verison to make it more like the original -\->
  <xsl:template match="section[@role='reference']" mode="toc"> 
    <xsl:param name="toc-context" select="."/>
  
    <xsl:call-template name="id.warning"/>
    
    <xsl:call-template name="toc.line">
      <xsl:with-param name="toc-context" select="$toc-context"/>
    </xsl:call-template>
  
    <xsl:variable name="nodes"
                  select="section | refentry | apiref | simplesect"/>
  
    <!-\- This extracts param values from generate.toc -\->
    <xsl:variable name="toc.params">
      <xsl:call-template name="find.path.params">
        <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
      </xsl:call-template>
    </xsl:variable>
  
    <!-\- <xsl:message>
      <xsl:text>******toc.params </xsl:text>
      <xsl:value-of select="$toc.params"/>
    </xsl:message> -\->
    
    <xsl:if test="$nodes">
      <div class="{name(.)}">
        <xsl:comment>Start of if block</xsl:comment>
        <xsl:call-template name="section.toc.separator"/>
  
        <!-\- Don't know what this does -\->
        <xsl:comment>Calling "dir"</xsl:comment>
        <xsl:call-template name="dir">
          <xsl:with-param name="inherit" select="1"/>
        </xsl:call-template>
  
        <xsl:comment>Calling section.toc</xsl:comment>
        <xsl:call-template name="section.toc">
          <xsl:with-param name="toc.title.p" select="contains($toc.params, 'title')"/>
        </xsl:call-template>
        <xsl:comment>Calling section.toc.separator</xsl:comment>
        <xsl:call-template name="section.toc.separator"/>
        <xsl:comment>Calling apply-templates, mode="toc"</xsl:comment>
        <xsl:apply-templates mode="toc" select="$nodes">
          <xsl:with-param name="toc-context" select="$toc-context"/>
        </xsl:apply-templates>
        <xsl:comment>Back from apply-templates</xsl:comment>
      </div>
    </xsl:if>
    <xsl:comment>End of if block</xsl:comment>
  </xsl:template> -->

  <!-- ============================================================= -->
  
  <!-- section.toc.separator appears between the toc title and the
       listing.  component.toc.separator appears between the listing
       and whatever comes after it. But if there's more than one toc,
       it only appears after the last one. -->
  <!-- <xsl:template name="section.toc.separator">
    <text>-\-\-(section.toc.separator)-\-\-</text>
  </xsl:template> -->
  <!-- <xsl:template name="component.toc.separator">
    <text>-\-\-(component.toc.seprator)-\-\-</text>
  </xsl:template> -->

  <!-- ============================================================= -->  

  <!-- Another version from Gemini.   This doesn't use mode="toc"
       I don't see where it generates the toc, either.
  -->
  <!-- <xsl:template match="section[@role='reference']">
    <div class="section-reference" style="border-left: 3px solid #0056b3; padding-left: 10px; margin-bottom: 20px;">
      <!-\- Generate anchors for linking/TOC -\->
      <xsl:call-template name="anchor"/>
      
      <!-\- Customizing the section title styling -\->
      <div class="reference-title" style="color: #0056b3; font-weight: bold;">
        <xsl:call-template name="section.heading">
          <xsl:with-param name="level" select="count(ancestor::section)+1"/>
        </xsl:call-template>
      </div>
  
      <!-\- Apply templates to the rest of the section content -\->
      <xsl:apply-templates select="node()[not(self::title or self::titleabbrev)]"/>
    </div>
  </xsl:template> -->

  <!-- ============================================================= -->

  <!-- Use deeper TOC in reference sections.  This code suggested by
       Muse-Glimmer-30b on NIST rchat. (But I don't see tocdepth in
       the docbook xsl files at all).
  -->

  
  <!-- <xsl:template match="section[@role='reference']">
    <xsl:copy>
      <xsl:attribute name="tocdepth">2</xsl:attribute>
      <xsl:apply-templates select="@*[name()!='role']|node()"/>
    </xsl:copy>
  </xsl:template> -->

  <!-- ============================================================= -->

  <!-- This doesn't work.  There's no generate.toc template to
       override. Gemini fail. -->
  <!-- <xsl:template name="generate.toc">
    <xsl:param name="node" select="."/>
    <xsl:message terminate='yes'>
      <xsl:text>generate.toc: </xsl:text>
      <xsl:copy-of select="."/>
    </xsl:message>
    
    <xsl:choose>
      <!-\- Look for sections that have an ancestor with role=reference
      -\->
      <xsl:when test="//section[ancestor-or-self::*[@role='reference']]">
        <xsl:message>
          <xsl:text>Creating toc for node </xsl:text>
          <xsl:copy-of select="."/>
        </xsl:message>
        1
      </xsl:when>
      
      <!-\- Fall back to the default DocBook behavior for everything else -\->
      <xsl:otherwise>
        <xsl:variable name="toc.params">
          <xsl:call-template name="find.path.params">
            <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
          </xsl:call-template>
        </xsl:variable>
        
        <xsl:value-of select="contains($toc.params, 'toc')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> -->
  
  <!-- <xsl:param name="generate.section.toc.level" select="1"/>
  <xsl:template match="section[@role='reference']" mode="toc">
    <xsl:comment>
      <xsl:text>==== generate.section.toc.level= </xsl:text>
      <xsl:value-of select="generate.section.toc.level"/>
    </xsl:comment>
  
    <xsl:apply-imports />
  </xsl:template> -->

  <!-- ============================================================= -->
  
  <!-- Keep certain items out of tables of contents by giving them an
       empty mode="toc" template. -->
  <xsl:template match="section[@role='Menu']" mode="toc"/>
  <xsl:template match="section[@role='Submenus']" mode="toc"/>
  <xsl:template match="section[@role='CommandListing']" mode="toc"/>
  <xsl:template match="refentry[@role='MenuItem']" mode="toc"/>
  <!-- This is a hack, I think. Without it, the links to subsections
       at the top of CH_extendingref.xml go to separate files, instead
       of to the subsection TOCs that are on the same page.  Having
       the links go to separate files would be ok, but the files don't
       exist.

       See the comment in CH_extendingref.xml -->
  <!-- <xsl:template match="section[@role='reference']" mode="toc"/> -->

  <!-- End of TOC tweaking -->
  
  <!-- ============================================================= -->

  <!-- This makes equation titles appear as "(1.1)" instead of
       "Equation 1.1. Title" -->
  <xsl:param name="local.l10n.xml" select="document('')"/>
  <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
    <l:l10n language="en">
      <l:context name="title">
        <l:template name="equation" text="(%n)"/>
      </l:context>
      <l:context name="xref-number">
        <l:template name="equation" text="(%n)"/>
      </l:context>
      <l:context name="xref-number-and-title">
        <l:template name="equation" text="Eq.&#160;(%n)"/> <!--use nbsp-->
      </l:context>
    </l:l10n>
  </l:i18n>

  <!-- Customization parameters -->

  <!-- number sections, and include chapter number in section number -->
  <xsl:param name="section.autolabel" select="1"/>
  <xsl:param name="section.label.includes.component.label" select="1"/>

  <!-- use graphics for "caution", "warning", etc. -->
  <xsl:param name="admon.graphics" select="1"/>
  <xsl:param name="admon.graphics.path" select="'IMAGES/'"/>
  <xsl:param name="admon.graphics.extension" select="'.png'"/>

  <!-- set the path to the callout icons -->
  <xsl:param name="callout.graphics.path" select="'IMAGES/callouts/'"/>
  <xsl:param name="callout.graphics.number.limit" select="'20'"/>

  <!-- use graphics for navigation -->
  <xsl:param name="navig.graphics" select="1"/>
  <xsl:param name="navig.graphics.path" select="'IMAGES/'"/>
  <xsl:param name="navig.graphics.extension" select="'.png'"/>

  <xsl:param name="formal.title.placement">
    equation after
  </xsl:param>

  <xsl:param name="funcsynopsis.tabular.threshold">
    50
  </xsl:param>

  <!-- CommandListing sections are just a collection of refentries.
  The refentries are referred to in the parent element, so the
  CommandListing section doesn't have to do anything at all.  This
  suppresses it, by doing only minimal processing. -->
  <!-- NOT USED -->
  <xsl:template match="section[@role='CommandListing']">
    <xsl:variable name="id">
      <xsl:call-template name="object.id"/>
    </xsl:variable>
    <div class="{name(.)}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- Modification of the stock cpp methodsynopsis template so that
  it indents like the java version does. -->

  <xsl:template mode="cpp"
    match="constructorsynopsis|destructorsynopsis|methodsynopsis">
    <xsl:variable name="start-modifiers" select="modifier[following-sibling::*[name(.) != 'modifier']]"/>
    <xsl:variable name="notmod" select="*[name(.) != 'modifier']"/>
    <xsl:variable name="end-modifiers" select="modifier[preceding-sibling::*[name(.) != 'modifier']]"/>
    <xsl:variable name="decl">
      <xsl:if test="parent::classsynopsis">
        <xsl:text>&nbsp;&nbsp;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="$start-modifiers" mode="cpp"/>
      
      <!-- type -->
      <xsl:if test="name($notmod[1]) != 'methodname'">
        <xsl:apply-templates select="$notmod[1]" mode="cpp"/>
      </xsl:if>

      <xsl:apply-templates select="methodname" mode="cpp"/>
    </xsl:variable>

    <code class="{name(.)}">
      <xsl:copy-of select="$decl"/>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="methodparam" mode="cpp">
        <xsl:with-param name="indent" select="string-length($decl)"/>
      </xsl:apply-templates>
      <xsl:text>)</xsl:text>
      <xsl:if test="exceptionname">
        <br/>
        <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp;throws&nbsp;</xsl:text>
        <xsl:apply-templates select="exceptionname" mode="cpp"/>
      </xsl:if>
      <xsl:if test="modifier[preceding-sibling::*[name(.) != 'modifier']]">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="$end-modifiers" mode="cpp"/>
      </xsl:if>
      <xsl:text>;</xsl:text>
    </code>
    <xsl:call-template name="synop-break"/>
  </xsl:template>

  <xsl:template match="methodparam" mode="cpp">
    <xsl:param name="indent">0</xsl:param>
    <xsl:if test="position() &gt; 1">
      <xsl:text>,</xsl:text>
      <br/>
      <xsl:if test="$indent &gt; 0">
        <xsl:call-template name="copy-string">
          <xsl:with-param name="string">&nbsp;</xsl:with-param>
          <xsl:with-param name="count" select="$indent + 1"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
    <span class="{name(.)}">
      <xsl:apply-templates mode="cpp"/>
    </span>
  </xsl:template>

  <!-- Modified classsynopsis template that writes "class" before the name -->
  <xsl:template match="classsynopsis" mode="cpp">
    <pre class="{name(.)}">
      <xsl:text>class </xsl:text> <!-- this line added by SAL -->
      <xsl:apply-templates select="ooclass[1]" mode="cpp"/>
      <xsl:if test="ooclass[position() &gt; 1]">
        <xsl:text>: </xsl:text>
        <xsl:apply-templates select="ooclass[position() &gt; 1]" mode="cpp"/>
        <xsl:if test="oointerface|ooexception">
          <br/>
          <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="oointerface">
        <xsl:text> implements</xsl:text>
        <xsl:apply-templates select="oointerface" mode="cpp"/>
        <xsl:if test="ooexception">
          <br/>
          <xsl:text>&nbsp;&nbsp;&nbsp;&nbsp;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="ooexception">
        <xsl:text> throws</xsl:text>
        <xsl:apply-templates select="ooexception" mode="cpp"/>
      </xsl:if>
      <xsl:text>&nbsp;{</xsl:text>
      <br/>
      <xsl:apply-templates select="constructorsynopsis
                                   |destructorsynopsis
                                   |fieldsynopsis
                                   |methodsynopsis
                                   |classsynopsisinfo" mode="cpp"/>
      <xsl:text>}</xsl:text>
    </pre>
  </xsl:template>


  <!-- 
       Modified latex-math templates, This allows the equation number
       to appear either on the left or the right, depending on whether the
       parameter formal.title.placement is "before" or "after"
       -->

  <xsl:template name="equation.number.td">
    <xsl:param name="class" select="local-name(.)"/>
    <td align="left" width="8%">
      <xsl:call-template name="anchor">
        <xsl:with-param name="conditional" select="0"/>
      </xsl:call-template>
      <xsl:if test="$class = 'equation'">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="." mode="label.markup"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </td>
  </xsl:template>

  <xsl:template name="equation.body.td">
    <xsl:param name="alignment" select="left"/>
    <td align="{$alignment}">
      <xsl:call-template name="auto.latex.filename"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <xsl:template match="equation">
    <xsl:call-template name="equations.common"/>
  </xsl:template>

  <xsl:template name="equations.common">
    <xsl:param name="class" select="local-name(.)"/>
    <xsl:variable name="alignment">
      <xsl:choose>
        <xsl:when test="@role and (@role = 'cont' or substring(@role,1,4)='term')">
          <xsl:text>left</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>center</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="param.placement"
      select="substring-after(normalize-space($formal.title.placement), concat(local-name(.), ' '))"/>

    <xsl:variable name="placement">
      <xsl:choose>
        <xsl:when test="contains($param.placement, ' ')">
          <xsl:value-of select="substring-before($param.placement, ' ')"/>
        </xsl:when>
        <xsl:when test="$param.placement = ''">before</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$param.placement"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <div class="equation">
      <table border="0" width="100%" summary="{$class}">
        <tr>
          <xsl:choose>
            <xsl:when test="$placement = 'before'">
              <xsl:call-template name="equation.number.td">
                <xsl:with-param name="class" select="$class"/>
              </xsl:call-template>
              <xsl:call-template name="equation.body.td">
                <xsl:with-param name="alignment" select="$alignment"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="equation.body.td">
                <xsl:with-param name="alignment" select="$alignment"/>
              </xsl:call-template>
              <xsl:call-template name="equation.number.td">
                <xsl:with-param name="class" select="$class"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
      </table>
    </div>
  </xsl:template>

  <!-- save some typing by defining <b> for bold -->
  <xsl:template match="b">
    <emphasis role="bold">
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  <!-- items copied directly from latex-math/custom-math.xsl -->
<xsl:variable name="tex.math.in.alt">latex</xsl:variable>
<xsl:variable name="tex.math.delims">0</xsl:variable>
<xsl:variable name="spacing.paras">0</xsl:variable>
<xsl:variable name="pre.spacing.paras">0</xsl:variable>
<xsl:variable name="post.spacing.paras">0</xsl:variable>
<xsl:variable name="xref.with.number.and.title">0</xsl:variable>
<xsl:variable name="passivetex.extensions">1</xsl:variable>




</xsl:stylesheet>
