<?xml version='1.0'?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp "&#160;">
]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
		        version="1.0"
                exclude-result-prefixes="exsl">


  <xsl:import href="docbook-xsl-4.5/html/docbook.xsl"/>
  <xsl:import href="docbook-xsl-4.5/html/chunk-common.xsl"/>
  <xsl:import href="latex-math/xsl/latex-math.xsl"/>
  <xsl:include href="docbook-xsl-4.5/html/chunk-code.xsl"/>

  <!-- Customized templates -->
  <xsl:include href="pysynop.xsl"/> <!-- python reference page synopsis -->
  <xsl:include href="nistexit.xsl"/> <!-- redirect external URLs -->
  <xsl:include href="fonts.xsl"/>    <!-- typography twiddling -->
  

  <!-- Customization parameters -->

  <!-- chunking -->
  <xsl:param name="use.id.as.filename" select="1"/>
  <xsl:param name="chunk.section.depth" select="5"/>


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

  <!-- ======================================= -->

  <!-- Table of Contents and Chunking Stuff -->
  
  <!-- Modification to generate.toc so that lists of equations and
       figures are *not* generated.  To restore figures, add 'figure'
       to the 'book' line -->
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

  <!-- Keep certain items out of tables of contents by giving them an
       empty mode="toc" template. -->
  <xsl:template match="section[@role='Menu']" mode="toc"/>
  <xsl:template match="section[@role='Submenus']" mode="toc"/>
  <xsl:template match="section[@role='CommandListing']" mode="toc"/>
  <xsl:template match="refentry[@role='MenuItem']" mode="toc"/>

  <!-- Reduce the size of tables of contents by limiting their depth. -->
  <xsl:param name="toc.section.depth">1</xsl:param>

  <!-- === -->

  <!-- Sections with role="reference" and their subsections are all
       chunks.  It doesn't seem to be possible to modify the chunk
       template without copying all of it here.  The original is in
       chunk-common.xsl.
  -->
  <xsl:template name="chunk">
    <xsl:param name="node" select="."/>
    <!-- returns 1 if $node is a chunk -->

    <!-- ==================================================================== -->
    <!-- What's a chunk?

         The root element
         appendix
         article
         bibliography  in article or part or book
         book
         chapter
         colophon
         glossary      in article or part or book
         index         in article or part or book
         part
         preface
         refentry
         reference
         sect{1,2,3,4,5}  if position()>1 && depth < chunk.section.depth
         section          if position()>1 && depth < chunk.section.depth
         set
         setindex
    -->
    <!-- ==================================================================== -->

    <!--
        <xsl:message>
        <xsl:text>chunk: </xsl:text>
        <xsl:value-of select="name($node)"/>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="$node/@id"/>
        <xsl:text>)</xsl:text>
        <xsl:text> csd: </xsl:text>
        <xsl:value-of select="$chunk.section.depth"/>
        <xsl:text> cfs: </xsl:text>
        <xsl:value-of select="$chunk.first.sections"/>
        <xsl:text> ps: </xsl:text>
        <xsl:value-of select="count($node/parent::section)"/>
        <xsl:text> prs: </xsl:text>
        <xsl:value-of select="count($node/preceding-sibling::section)"/>
        </xsl:message>
    -->

    <xsl:choose>
      <xsl:when test="$node/ancestor-or-self::section[@role='reference']">
        1
      </xsl:when>
	  <xsl:when test="$node/parent::*/processing-instruction('dbhtml')[normalize-space(.) = 'stop-chunking']">0</xsl:when>
      <xsl:when test="not($node/parent::*)">1</xsl:when>

      <xsl:when test="local-name($node) = 'sect1'
                      and $chunk.section.depth &gt;= 1
                      and ($chunk.first.sections != 0
                      or count($node/preceding-sibling::sect1) &gt; 0)">
        1
      </xsl:when>
      <xsl:when test="local-name($node) = 'sect2'
                      and $chunk.section.depth &gt;= 2
                      and ($chunk.first.sections != 0
                      or count($node/preceding-sibling::sect2) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="local-name($node) = 'sect3'
                      and $chunk.section.depth &gt;= 3
                      and ($chunk.first.sections != 0
                      or count($node/preceding-sibling::sect3) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="local-name($node) = 'sect4'
                      and $chunk.section.depth &gt;= 4
                      and ($chunk.first.sections != 0
                      or count($node/preceding-sibling::sect4) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="local-name($node) = 'sect5'
                      and $chunk.section.depth &gt;= 5
                      and ($chunk.first.sections != 0
                      or count($node/preceding-sibling::sect5) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>
      
      <xsl:when test="local-name($node) = 'section'
                      and $chunk.section.depth &gt;= count($node/ancestor::section)+1
                      and ($chunk.first.sections != 0
                      or count($node/preceding-sibling::section) &gt; 0)">
        <xsl:call-template name="chunk">
          <xsl:with-param name="node" select="$node/parent::*"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="local-name($node)='preface'">1</xsl:when>
      <xsl:when test="local-name($node)='chapter'">1</xsl:when>
      <xsl:when test="local-name($node)='appendix'">1</xsl:when>
      <xsl:when test="local-name($node)='article'">1</xsl:when>
      <xsl:when test="local-name($node)='part'">1</xsl:when>
      <xsl:when test="local-name($node)='reference'">1</xsl:when>
      <xsl:when test="local-name($node)='refentry'">1</xsl:when>
      <xsl:when test="local-name($node)='index' and ($generate.index != 0 or count($node/*) > 0)
                      and (local-name($node/parent::*) = 'article'
                      or local-name($node/parent::*) = 'book'
                      or local-name($node/parent::*) = 'part'
                      )">1</xsl:when>
      <xsl:when test="local-name($node)='bibliography'
                      and (local-name($node/parent::*) = 'article'
                      or local-name($node/parent::*) = 'book'
                      or local-name($node/parent::*) = 'part'
                      )">1</xsl:when>
      <xsl:when test="local-name($node)='glossary'
                      and (local-name($node/parent::*) = 'article'
                      or local-name($node/parent::*) = 'book'
                      or local-name($node/parent::*) = 'part'
                      )">1</xsl:when>
      <xsl:when test="local-name($node)='colophon'">1</xsl:when>
      <xsl:when test="local-name($node)='book'">1</xsl:when>
      <xsl:when test="local-name($node)='set'">1</xsl:when>
      <xsl:when test="local-name($node)='setindex'">1</xsl:when>
      <xsl:when test="local-name($node)='legalnotice'
                      and $generate.legalnotice.link != 0">1</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:template>                 <!-- chunk -->

  <!-- === -->

  <!-- Sections with role='reference' build a toc for themselves and
       all subsections.  The original is in sections.xsl. -->
  <xsl:template
      match="section[ancestor-or-self::*[@role='reference']]"
      priority="2">
    <xsl:comment>section role=reference</xsl:comment>
    <div class="{name(.)}">
      <xsl:call-template name="common.html.attributes">
        <xsl:with-param name="inherit" select="1"/>
      </xsl:call-template>
      <xsl:call-template name="section.titlepage"/>
      
      <xsl:variable name="toc.params">
        <xsl:call-template name="find.path.params">
          <xsl:with-param name="table" select="normalize-space($generate.toc)"/>
        </xsl:call-template>
      </xsl:variable>
  
      <!-- Build the toc unconditionally -->
      <xsl:call-template name="section.toc">
        <xsl:with-param name="toc-title" select="'In this reference section:'"/>
      </xsl:call-template>
      <xsl:call-template name="section.toc.separator"/>

      <xsl:comment>section role=reference calling apply-templates</xsl:comment>
      <xsl:apply-templates/>
      <xsl:comment>section role=reference back from apply-templates</xsl:comment>
      <xsl:call-template name="process.chunk.footnotes"/>
    </div>
    <xsl:comment>end section role=reference</xsl:comment>
  </xsl:template>               <!-- section -->

  <!-- ==== -->

  <!-- file names for <refentry> elements in role=reference sections
       aren't being created correctly.  Maybe docbook expects them to
       be inside <reference> elements (although putting <refentry>s in
       a <section> doesn't violate the dtd.)  The original version of
       this template is in chunk-code.xsl. -->

  <xsl:template match="refentry" mode="chunk-filename">
    <xsl:param name="base.dir" select="'./'"/>
    <xsl:param name="base.name" select="''"/>
    <xsl:comment>refentry chunk-filename</xsl:comment>
    <!-- <xsl:message>
      <xsl:text>refentry chunk-filename: </xsl:text>
      <xsl:value-of select="name()"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:if test="$base.dir">
        <xsl:text> base.dir=</xsl:text>
        <xsl:value-of select="$base.dir"/>
      </xsl:if>
    </xsl:message> -->

    <xsl:variable name="dirname">
      <xsl:choose>
      <xsl:when test="$base.dir">
        <xsl:value-of select="$base.dir"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>./</xsl:text>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="$base.name">
          <xsl:value-of select="$base.name"/>
        </xsl:when>
        <xsl:when test="$use.id.as.filename != 0 and @id">
          <xsl:value-of select="@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>refentry-</xsl:text>
          <xsl:number level="any" count="refentry"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- <xsl:message>
      <xsl:text>    </xsl:text>
      <xsl:value-of select="concat($dirname, $filename, '.html')"/>
    </xsl:message> -->

    <xsl:value-of select="concat($dirname, $filename)"/>
    <xsl:comment>end refentry chunk-filename</xsl:comment>
  </xsl:template>      <!-- match="refentry" mode="chunk-filename" -->

  <!-- <xsl:template name="make-relative-filename" match="refentry">
    <xsl:param name="base.dir" select="'./'"/>
    <xsl:param name="base.name" select="''"/>
    <xsl:comment>make-relative-filename match=refentry"</xsl:comment>
    <xsl:variable name="dirname">
      <xsl:choose>
      <xsl:when test="$base.dir">
        <xsl:value-of select="$base.dir"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>./</xsl:text>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="filename">
      <xsl:choose>
        <xsl:when test="$base.name">
          <xsl:value-of select="$base.name"/>
        </xsl:when>
        <xsl:when test="$use.id.as.filename != 0 and @id">
          <xsl:value-of select="@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>refentry-</xsl:text>
          <xsl:number level="any" count="refentry"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-\- The following line prints the file name in the html output,
         which means that this template is being applied outside of a
         variable or param template, I think. -\->
    <xsl:value-of select="concat($dirname, $filename)"/>
    <xsl:comment>make-relative-filename match=refentry done"</xsl:comment>
  </xsl:template> -->
 
  <!-- =========================================== -->
  
  <!-- new version of chunk-element-content that leaves out everything
       but the content of the body tag, because the ctcms wrapper
       expects just the body content.  The original version is in
       chunk-common.xsl. -->
  <xsl:template name="chunk-element-content" priority="1">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content">
      <xsl:apply-imports/>
    </xsl:param>
  
    <xsl:call-template name="user.preroot"/>
  
    <xsl:call-template name="body.attributes"/>
    <xsl:call-template name="user.header.navigation"/>
  
    <xsl:call-template name="header.navigation">
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="nav.context" select="$nav.context"/>
    </xsl:call-template>
  
    <xsl:call-template name="user.header.content"/>
    
    <xsl:copy-of select="$content"/>
  
    <xsl:call-template name="user.footer.content"/>
    
    <xsl:call-template name="footer.navigation">
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="nav.context" select="$nav.context"/>
    </xsl:call-template>
    <xsl:call-template name="user.footer.navigation"/>
  </xsl:template>             <!--chunk-element-content -->


  <!-- ======================================= -->

  <!-- Equation Stuff -->

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

  <!-- Other Stuff -->

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

  <!-- save some typing by defining <b> for bold -->
  <xsl:template match="b">
    <emphasis role="bold">
      <xsl:apply-templates/>
    </emphasis>
  </xsl:template>

  
</xsl:stylesheet>

  
