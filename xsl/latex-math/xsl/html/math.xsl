<!--
<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>
  -->

<!-- ********************************************************************
     $Id: math.xsl,v 1.9 2002/12/17 00:55:53 bobstayton Exp $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->
<!-- also modify informal.object to 
   <xsl:call-template name="auto.latex.filename"/>
   only for informalequations  -->

<xsl:param name="equations.graphics.path" select="'equations/'"/>
<xsl:param name="equations.graphics.extension" select="'.gif'"/>
<xsl:param name="equations.graphics.vertical.align" select="'1'"/>
<xsl:param name="tex.inline.math.file"    select="'tex-math-inlines.tex'"/>

<xsl:template match="inlineequation">
  <xsl:apply-templates/>
  <xsl:call-template name="auto.latex.filename"/>
</xsl:template>

<xsl:template match="alt">
</xsl:template>

<!-- "Support" for MathML -->

<xsl:template match="mml:*" xmlns:mml="http://www.w3.org/1998/Math/MathML">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!-- Support for TeX math in alt -->

<xsl:template match="*" mode="collect.tex.math">
  <xsl:call-template name="channel.tex.math.to.file">
    <xsl:with-param name="filename" select="$tex.math.file"/>
    <xsl:with-param name="children" select=".//equation|.//informalequation"/>
  </xsl:call-template>
  <xsl:call-template name="channel.tex.math.to.file">
    <xsl:with-param name="filename" select="$tex.inline.math.file"/>
    <xsl:with-param name="children" select=".//inlineequation"/>
  </xsl:call-template>
</xsl:template>


<xsl:template name="channel.tex.math.to.file">
  <xsl:param name="filename" select="''"/>
  <xsl:param name="children" select="''"/>

  <xsl:call-template name="write.text.chunk">
    <xsl:with-param name="filename" >
      <xsl:call-template name="make-relative-filename">
        <xsl:with-param name="base.dir">
          <xsl:call-template name="target.doc.dir.path">
            <xsl:with-param name="doc.node" select="."/>
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="base.name" select="$filename"/>
      </xsl:call-template>
    </xsl:with-param >
    <xsl:with-param name="method" select="'text'"/>
    <xsl:with-param name="content">
      <xsl:choose>
        <xsl:when test="$tex.math.in.alt = 'plain'">
          <xsl:call-template name="tex.math.plain.head"/>
          <xsl:apply-templates select="$children" mode="collect.tex.math.plain"/>
          <xsl:call-template name="tex.math.plain.tail"/>
        </xsl:when>
        <xsl:when test="$tex.math.in.alt = 'latex'">
          <xsl:call-template name="tex.math.latex.head"/>
          <xsl:apply-templates select="$children" mode="collect.tex.math.latex"/>
          <xsl:call-template name="tex.math.latex.tail"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            Unsupported TeX math notation: 
            <xsl:value-of select="$tex.math.in.alt"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:with-param>
    <xsl:with-param name="encoding" select="$chunker.output.encoding"/>
  </xsl:call-template>
</xsl:template>

<!-- PlainTeX -->

<xsl:template name="tex.math.plain.head">
  <xsl:text>\nopagenumbers &#xA;</xsl:text>
</xsl:template>

<xsl:template name="tex.math.plain.tail">
  <xsl:text>\bye &#xA;</xsl:text>
</xsl:template>

<xsl:template match="inlineequation" mode="collect.tex.math.plain">
  <xsl:variable name="filename">
    <xsl:call-template name="get.math.img.filename"/>
  </xsl:variable>
  <xsl:variable name="output.delims">
    <xsl:call-template name="tex.math.output.delims"/>
  </xsl:variable>
  <xsl:variable name="tex" select="alt[@role='tex'] | inlinemediaobject/textobject[@role='tex']"/>
  <xsl:if test="$tex">
    <xsl:if test="$equations.graphics.vertical.align">
       <xsl:text>\noindent\special{dvi2bitmap mark}&#xA;</xsl:text>
    </xsl:if>
    <xsl:text>\special{dvi2bitmap outputfile </xsl:text>
    <xsl:value-of select="$filename"/>
    <xsl:text>} &#xA;</xsl:text>
    <xsl:if test="$output.delims != 0">
      <xsl:text>$</xsl:text>
    </xsl:if>
    <xsl:value-of select="$tex"/>
    <xsl:if test="$output.delims != 0">
      <xsl:text>$ &#xA;</xsl:text>
    </xsl:if>
    <xsl:text>\vfill\eject &#xA;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="equation|informalequation" mode="collect.tex.math.plain">
  <xsl:variable name="filename">
     <xsl:call-template name="get.math.img.filename"/>
  </xsl:variable>
  <xsl:variable name="output.delims">
    <xsl:call-template name="tex.math.output.delims"/>
  </xsl:variable>
  <xsl:variable name="tex" select="alt[@role='tex'] | mediaobject/textobject[@role='tex']"/>
  <xsl:if test="$tex">
    <xsl:text>\special{dvi2bitmap outputfile </xsl:text>
    <xsl:value-of select="$filename"/>
    <xsl:text>} &#xA;</xsl:text>
    <xsl:if test="$output.delims != 0">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:value-of select="$tex"/>
    <xsl:if test="$output.delims != 0">
      <xsl:text>$$ &#xA;</xsl:text>
    </xsl:if>
    <xsl:text>\vfill\eject &#xA;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="text()" mode="collect.tex.math.plain"/>

<!-- LaTeX -->

<xsl:template name="tex.math.latex.head">
  <xsl:text>\documentclass{article} &#xA;</xsl:text>
  <xsl:text>\pagestyle{empty} &#xA;</xsl:text>
  <xsl:text>\begin{document} &#xA;</xsl:text>
</xsl:template>

<xsl:template name="tex.math.latex.tail">
  <xsl:text>\end{document} &#xA;</xsl:text>
</xsl:template>

<xsl:template match="inlineequation" mode="collect.tex.math.latex">
  <xsl:variable name="filename">
    <xsl:call-template name="get.math.img.filename"/>
  </xsl:variable>
  <xsl:variable name="output.delims">
    <xsl:call-template name="tex.math.output.delims"/>
  </xsl:variable>
  <xsl:variable name="tex" select="alt[@role='tex'] | inlinemediaobject/textobject[@role='tex']"/>
  <xsl:if test="$tex">
    <xsl:text>\special{dvi2bitmap outputfile </xsl:text>
    <xsl:value-of select="$filename"/>
    <xsl:text>} &#xA;</xsl:text>
    <xsl:if test="$equations.graphics.vertical.align">
       <xsl:text>\noindent\special{dvi2bitmap mark}&#xA;</xsl:text>
    </xsl:if>
    <xsl:if test="$output.delims != 0">  
      <xsl:text>$</xsl:text>
    </xsl:if>
    <xsl:value-of select="$tex"/>
    <xsl:if test="$output.delims != 0">  
      <xsl:text>$ &#xA;</xsl:text>
    </xsl:if>
    <xsl:text>\newpage &#xA;</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="equation|informalequation" mode="collect.tex.math.latex">
  <xsl:variable name="filename">
    <xsl:call-template name="get.math.img.filename"/>
  </xsl:variable>
  <xsl:variable name="output.delims">
    <xsl:call-template name="tex.math.output.delims"/>
  </xsl:variable>
  <xsl:variable name="tex" select="alt[@role='tex'] | mediaobject/textobject[@role='tex']"/>
  <xsl:if test="$tex">

    <xsl:choose>
      <xsl:when test="@role and (@role = 'cont' or substring(@role,1,4)='term')">
       <xsl:text>\special{dvi2bitmap absolute crop left 0 } &#xA;</xsl:text>
        <xsl:text>\special{dvi2bitmap outputfile </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\special{dvi2bitmap outputfile </xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:value-of select="$filename"/>
    <xsl:text>} &#xA;</xsl:text>
    <xsl:if test="$output.delims != 0">
      <xsl:text>$$</xsl:text>
    </xsl:if>
    <xsl:value-of select="$tex"/>
    <xsl:if test="$output.delims != 0">
      <xsl:text>$$ &#xA;</xsl:text>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="@role and @role = 'cont'">
        <xsl:text>\displaybreak\\&#xA;</xsl:text>
      </xsl:when>
      <xsl:otherwise><xsl:text>\newpage &#xA;</xsl:text></xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>

<xsl:template match="text()" mode="collect.tex.math.latex"/>

<!-- Extracting image filename from mediaobject and graphic elements -->

<xsl:template name="select.mediaobject.filename">
  <xsl:param name="olist"
             select="imageobject|imageobjectco
                     |videoobject|audioobject|textobject"/>

  <xsl:variable name="mediaobject.index">
    <xsl:call-template name="select.mediaobject.index">
      <xsl:with-param name="olist" select="$olist"/>
      <xsl:with-param name="count" select="1"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$mediaobject.index != ''">
    <xsl:call-template name="mediaobject.filename">
      <xsl:with-param name="object"
                      select="$olist[position() = $mediaobject.index]"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="tex.math.output.delims">
  <xsl:variable name="pi.delims">
    <xsl:call-template name="pi-attribute">
      <xsl:with-param name="pis" select=".//processing-instruction('dbtex')"/>
      <xsl:with-param name="attribute" select="'delims'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="result">
    <xsl:choose>
      <xsl:when test="$pi.delims = 'no'">0</xsl:when>
      <xsl:when test="$pi.delims = '' and $tex.math.delims = 0">0</xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$result"/>
</xsl:template>

<xsl:template name="auto.latex.filename">
  <xsl:variable name="inline">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'informalequation'">
        <xsl:text></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>inline</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="graphic"/>
    <xsl:when test="mediaobject"/>
    <xsl:when test="inlinemediaobject"/>
    <xsl:otherwise>  <!-- no object - filename supplied, so create -->
      <xsl:variable name="filename">
        <xsl:call-template name="create.latex.image.filename"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$inline != ''">
          <span class="{$inline}mediaobject">
            <!--img src="{$filename}" align="absmiddle"/ -->
            <img src="{$filename}" >
               <xsl:attribute name="alt">
                 <xsl:value-of select=".//alt"/>
               </xsl:attribute>
            </img>
          </span>
        </xsl:when>
        <xsl:otherwise>
          <div class="mediaobject">
            <img src="{$filename}">
               <xsl:attribute name="alt">
                 <xsl:value-of select=".//alt"/>
               </xsl:attribute>
            </img>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template name="get.math.img.filename">
  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="graphic">
        <xsl:call-template name="mediaobject.filename">
          <xsl:with-param name="object" select="graphic"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="mediaobject">
        <xsl:call-template name="select.mediaobject.filename">
          <xsl:with-param name="olist" select="mediaobject/*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="inlinemediaobject">
        <xsl:call-template name="select.mediaobject.filename">
          <xsl:with-param name="olist" select="inlinemediaobject/*"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="create.latex.image.filename"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$filename"/>
</xsl:template>

<xsl:template name="create.latex.image.filename">
  <xsl:variable name="level">
    <xsl:number level="multiple" 
              count="chapter|appendix|section|subsection|
                     sect|sect1|sect2|sect3|sect4|sect5|sect6"/>
  </xsl:variable>
  <xsl:variable name="sequ">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'informalequation'">
        <xsl:text>-inf-</xsl:text>
        <xsl:number level="any" from="section"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'equation'">
        <xsl:text>-eq-</xsl:text>
        <xsl:number level="any" from="section"/>
      </xsl:when>
      <xsl:when test="local-name(.) = 'inlineequation'">
        <xsl:text>-inl-</xsl:text>
        <xsl:number level="any" from="section"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>-eqxx-</xsl:text>
        <xsl:number level="any" from="section"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:value-of select="concat($equations.graphics.path,$level,$sequ,$equations.graphics.extension)"/>
</xsl:template>

<!--
</xsl:stylesheet>
  -->
