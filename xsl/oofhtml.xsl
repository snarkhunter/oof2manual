<?xml version='1.0'?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="docbook-xsl-4.5/xhtml/docbook.xsl"/>
  <xsl:import href="latex-math/xsl/latex-math.xsl"/>

  <!-- Customized templates -->
  <xsl:include href="pysynop.xsl"/> <!-- python reference page synopsis -->
  <xsl:include href="nistexit.xsl"/> <!-- redirect external URLs -->
  <xsl:include href="fonts.xsl"/>  <!-- typography twiddling -->


  <!-- modification to generate.toc so that lists of equations and figures are
       *not* generated.  To restore figures, add 'figure' to the 'book' line -->
  <xsl:param name="generate.toc">
    appendix  toc,title
    article/appendix  nop
    article   toc,title
    book      toc,title,figure
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

  <!-- This is a modified version of the "section" template that
       always builds a table of contents. -->
  <xsl:template match="section[@role='reference']">
    <xsl:variable name="depth" select="count(ancestor::section)+1"/>

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
  </xsl:template>

  <!-- Keep the size of tables of contents down by limiting their depth. -->
  <xsl:param name="toc.section.depth">1</xsl:param>

  <!-- Keep certain items out of tables of contents by giving them an
       empty mode="toc" template. -->
  <xsl:template match="section[@role='Menu']" mode="toc"/>
  <xsl:template match="section[@role='Submenus']" mode="toc"/>
  <xsl:template match="section[@role='CommandListing']" mode="toc"/>
  <xsl:template match="refentry[@role='MenuItem']" mode="toc"/>

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
        <l:template name="equation" text="Eq.&#160;(%n)"/>
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

  <!-- items copied directly from latex-math/custom-math.xsl -->
<xsl:variable name="tex.math.in.alt">latex</xsl:variable>
<xsl:variable name="tex.math.delims">0</xsl:variable>
<xsl:variable name="spacing.paras">0</xsl:variable>
<xsl:variable name="pre.spacing.paras">0</xsl:variable>
<xsl:variable name="post.spacing.paras">0</xsl:variable>
<xsl:variable name="xref.with.number.and.title">0</xsl:variable>
<xsl:variable name="passivetex.extensions">1</xsl:variable>

<xsl:template name="tex.math.latex.head">
  <xsl:text>\documentclass[leqno,10pt]{revtex4} &#xA;</xsl:text>
  <xsl:text>\usepackage{amsmath} &#xA;</xsl:text>
  <!-- xsl:text>\usepackage{amsfonts} &#xA;</xsl:text -->
  <xsl:text>\usepackage{concmath} &#xA;</xsl:text>

  <xsl:text>\pagestyle{empty} &#xA;</xsl:text>
  <xsl:text>\begin{document} &#xA;</xsl:text>
  <xsl:text>\allowdisplaybreaks &#xA;</xsl:text>
</xsl:template>

</xsl:stylesheet>
