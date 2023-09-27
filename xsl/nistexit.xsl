<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Modify the ulink template so that URLs marked "role=external"
     are directed to the NIST exit page. -->

<!-- If nist.exit.script is true, then all external urls are routed
     through the nist exit script. -->

<xsl:param name="nist.exit.script" select="''"/>

<xsl:template match="ulink">
  <a>
    <xsl:if test="@id">
      <xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:if>
    <xsl:attribute name="href">
       <xsl:if test="@role='external' and $nist.exit.script != ''">
         <xsl:text>/cgi-bin/redirect.py?timeout=5&amp;url=</xsl:text>
       </xsl:if>
       <xsl:value-of select="@url"/>
    </xsl:attribute>
    <xsl:if test="$ulink.target != ''">
      <xsl:attribute name="target">
        <xsl:value-of select="$ulink.target"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="count(child::node())=0">
	<xsl:value-of select="@url"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </a>
</xsl:template>


</xsl:stylesheet>
