<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <!-- $RCSfile: fonts.xsl,v $ -->
  <!-- $Revision: 1.3 $ -->
  <!-- $Author: langer $ -->
  <!-- $Date: 2005/01/31 21:37:38 $ -->


  <!-- add some styles to the ones docbook provides.  It's probably
  bad form to rely on the face attribute, since it's an html
  extension. -->
  
  <xsl:template name="inline.sansserifseq">
    <xsl:param name="content">
      <xsl:if test="@id">
        <a name="{@id}"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:param>
    <font face="helvetica"><xsl:copy-of select="$content"/></font>
  </xsl:template>

  <xsl:template name="inline.boldsansserifseq">
    <xsl:param name="content">
      <xsl:if test="@id">
        <a name="{@id}"/>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:param>
    <b><font face="helvetica"><xsl:copy-of select="$content"/></font></b>
  </xsl:template>

  <!-- change the font choices for some elements -->
  <xsl:template match="application">
    <xsl:call-template name="inline.boldsansserifseq"/>
  </xsl:template>

  <xsl:template match="guimenuitem">
    <xsl:call-template name="inline.boldsansserifseq"/>
  </xsl:template>

  <xsl:template match="guimenu">
    <xsl:call-template name="inline.sansserifseq"/>
  </xsl:template>

  <!-- 
       Change the typography for xrefs to various things.  For each
       target, an insert.title.markup template must be provided, and the
       xref.xreflabel template must be modified.
   -->

  <xsl:template match="refentry[@role='Registration']"
    mode="insert.title.markup">
    <xsl:param name="purpose"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="title"/>
    <code class="classname"><xsl:copy-of select="$title"/></code>
  </xsl:template>

  <xsl:template match="refentry[@role='RegisteredClass']"
    mode="insert.title.markup">
    <xsl:param name="purpose"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="title"/>
    <code class="classname"><xsl:copy-of select="$title"/></code>
  </xsl:template>

  <xsl:template match="refentry[@role='MenuItem']"
    mode="insert.title.markup">
    <xsl:param name="purpose"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="title"/>
    <b><xsl:copy-of select="$title"/></b>
  </xsl:template>

  <xsl:template match="section[@role='Menu']"
    mode="insert.title.markup">
    <xsl:param name="purpose"/>
    <xsl:param name="xrefstyle"/>
    <xsl:param name="title"/>
    <b><xsl:copy-of select="$title"/></b>
  </xsl:template>

  <xsl:template name="xref.xreflabel">
    <xsl:param name="target" select="."/>
    <xsl:choose>
      <xsl:when test="$target/@role='Registration'">
        <code class="classname"><xsl:value-of select="$target/@xreflabel"/></code>      
      </xsl:when>
      <xsl:when test="$target/@role='RegisteredClass'">
        <code class="classname"><xsl:value-of select="$target/@xreflabel"/></code>      
      </xsl:when>
      <xsl:when test="$target/@role='MenuItem'">
        <b><xsl:value-of select="$target/@xreflabel"/></b>      
      </xsl:when>
      <xsl:when test="$target/@role='Menu'">
        <b><xsl:value-of select="$target/@xreflabel"/></b>      
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$target/@xreflabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
