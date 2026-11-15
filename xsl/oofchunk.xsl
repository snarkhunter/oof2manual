<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                		xmlns:exsl="http://exslt.org/common"
		version="1.0"
                exclude-result-prefixes="exsl">

  <!--
      Chunking is the separation of the document into separate html
      pages.  All chunking modifications for OOF must be in here, not
      in oofhtml.xsl.
      
      See https://sagehill.net/docbookxsl/ChunkingCustomization.html
      for important information about chunking.
  -->

  <xsl:import href="oofhtml.xsl"/>
  
  <!-- The order and effects of the following two lines are explained
       in the link above. -->
  <xsl:import href="docbook-xsl-4.5/html/chunk-common.xsl"/>
  <xsl:include href="docbook-xsl-4.5/html/chunk-code.xsl"/>

  <!-- Set parameters used by the chunking machinery -->
  <xsl:param name="use.id.as.filename" select="1"/>
  <xsl:param name="chunk.section.depth" select="1"/>
  <xsl:param name="chunk.first.sections" select="1"/>

  <!-- =========================================== -->

  <!-- Modified copy of the chunk template from chunk-common.xsl.  We
       want some <section>s to always be chunks, independent of their
       nesting depth. -->

  <xsl:template name="chunk" priority="1">
    <xsl:param name="node" select="."/>
    <!-- returns 1 if $node is a chunk -->
  
    <!-- ================================================================= -->
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
         topic
    -->
    <!-- ================================================================= -->
  
    <xsl:choose>
      <xsl:when test="$node/parent::*/processing-instruction('dbhtml')[normalize-space(.) = 'stop-chunking']">0</xsl:when>
      <xsl:when test="not($node/parent::*)">1</xsl:when>

      <!-- OOF modifications -->
      <xsl:when test="local-name($node) = 'section'
                      and ($node[@role='Menu'] |
                           $node[role='MenuItem'] |
                           $node[role='RootMenu'])">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <!-- end OOF modifications -->
      
      <xsl:when test="local-name($node) = 'sect1'
                      and $chunk.section.depth &gt;= 1
                      and ($chunk.first.sections != 0
                      or count($node/preceding-sibling::sect1) &gt; 0)">
        <xsl:text>1</xsl:text>
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
      <xsl:when test="local-name($node)='topic'">1</xsl:when>
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
  </xsl:template>               <!-- name="chunk" -->

  <!-- =========================================== -->
  
  <!-- chunk-filename is changed to ensure that names don't contain
       spaces or colons, which can occur in some automatically
       generated names in oof2_api.xml.  The original template in
       chunk-code.xsl. -->

  <xsl:template match="*" mode="chunk-filename" priority="1">
    <!-- returns the filename of a chunk -->
    <xsl:variable name="fn">
      <xsl:apply-templates select="." mode="recursive-chunk-filename"/>
    </xsl:variable>

    <xsl:if test="$fn != ''">
      <xsl:call-template name="dbhtml-dir"/>
    </xsl:if>

    <xsl:value-of select='translate($fn, ": ", "-_")'/>
  </xsl:template>               <!-- mode="chunk-filename" -->

  <!-- =========================================== -->
  
  <!-- New version of chunk-element-content that leaves out everything
       but the content of the body tag, because the ctcms wrapper
       script expects just the body content.  The original version of
       the template is in chunk-common.xsl.

       The original calls user.head.content, user.header.navigation,
       etc, that have to be redefined to be useful.  I've just deleted
       the calls here.
  -->
  
  <xsl:template name="chunk-element-content">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content">
      <xsl:apply-imports/>
    </xsl:param>

    <xsl:call-template name="user.preroot"/>

    <!-- <xsl:call-template name="body.attributes"/> -->

    <xsl:call-template name="user.header.navigation">
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="nav.context" select="$nav.context"/>
    </xsl:call-template>

    <xsl:call-template name="header.navigation">
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="nav.context" select="$nav.context"/>
    </xsl:call-template>

    <xsl:copy-of select="$content"/>

    <xsl:call-template name="footer.navigation">
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="nav.context" select="$nav.context"/>
    </xsl:call-template>

    <xsl:value-of select="$chunk.append"/>
  </xsl:template>               <!-- name="chunk-element-content" -->


  <!-- TODO: The "Next" button on the Main OOF Menu page is going to
       to the first ActiveArea command, instead of to the ActiveArea
       menu.  Is that because the <refentry>s for the commands are
       created before the <section>s for the menus? 
  -->
  
</xsl:stylesheet>
