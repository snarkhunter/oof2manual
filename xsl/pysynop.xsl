<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp "&#160;">
]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">

  <!-- Additions and modifications to html/synop.xsl so that it
       handles python synopses. -->

  <xsl:template match="classsynopsis
                       |fieldsynopsis
                       |methodsynopsis
                       |constructorsynopsis
                       |destructorsynopsis"
		priority="1">
    <xsl:param name="language">
      <xsl:choose>
        <xsl:when test="@language">
          <xsl:value-of select="@language"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default-classsynopsis-language"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$language='java'">
        <xsl:apply-templates select="." mode="java"/>
      </xsl:when>
      <xsl:when test="$language='perl'">
        <xsl:apply-templates select="." mode="perl"/>
      </xsl:when>
      <xsl:when test="$language='idl'">
        <xsl:apply-templates select="." mode="idl"/>
      </xsl:when>
      <xsl:when test="$language='cpp'">
        <xsl:apply-templates select="." mode="cpp"/>
      </xsl:when>
      <xsl:when test="$language='python'">
        <xsl:apply-templates select="." mode="python"/>
      </xsl:when>
      <xsl:when test="$language='cpp python'">
        <xsl:apply-templates select="." mode="cpp"/>
        <xsl:apply-templates select="." mode="python"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>Unrecognized language on </xsl:text>
          <xsl:value-of select="name(.)"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$language"/>
        </xsl:message>
        <xsl:apply-templates select=".">
          <xsl:with-param name="language"
            select="$default-classsynopsis-language"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="classsynopsis" mode="python" priority="1">
    <pre class="{name(.)}">
      <xsl:text>class </xsl:text>
      <xsl:apply-templates select="ooclass[1]" mode="python"/>
      <xsl:if test="ooclass[position() &gt; 1]">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="ooclass[position() &gt; 1]" mode="python"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text>:</xsl:text>
      <br/>
      <xsl:apply-templates select="constructorsynopsis
                                   |destructorsynopsis
                                   |fieldsynopsis
                                   |methodsynopsis
                                   |classsynopsisinfo" mode="python"/>
      <xsl:if test="count(constructorsynopsis
                    |destructorsynopsis
                    |fieldsynopsis
                    |methodsynopsis
                    |classsynopsisinfo) = 0">
        <xsl:text>   pass</xsl:text>
      </xsl:if>
    </pre>
  </xsl:template>

  <xsl:template match="classsynopsisinfo" mode="python">
    <xsl:apply-templates mode="python"/>
  </xsl:template>

  <xsl:template match="ooclass|oointerface" mode="python">
    <xsl:if test="position() &gt; 1">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <span class="{name(.)}">
      <xsl:apply-templates mode="python"/>
    </span>
  </xsl:template>

  <xsl:template match="classname" mode="python">
    <xsl:if test="name(preceding-sibling::*[1]) = 'classname'">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <span class="{name(.)}">
      <xsl:apply-templates mode="python"/>
    </span>
  </xsl:template>

  <xsl:template match="interfacename" mode="python">
    <xsl:if test="name(preceding-sibling::*[1]) = 'interfacename'">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <span class="{name(.)}">
      <xsl:apply-templates mode="python"/>
    </span>
  </xsl:template>

  <xsl:template match="fieldsynopsis" mode="python">
    <code class="{name(.)}">
      <xsl:if test="parent::classsynopsis">
        <xsl:text>&nbsp;&nbsp;</xsl:text>
      </xsl:if>
      <xsl:apply-templates mode="python"/>
    </code>
    <xsl:call-template name="synop-break"/>
  </xsl:template>

  <xsl:template match="varname" mode="python">
    <span class="{name(.)}">
      <xsl:apply-templates mode="python"/>
      <xsl:text>&nbsp;</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="initializer" mode="python">
    <span class="{name(.)}">
      <xsl:text>=&nbsp;</xsl:text>
      <xsl:apply-templates mode="python"/>
    </span>
  </xsl:template>


  <xsl:template match="void" mode="python"/>

  <xsl:template match="methodname" mode="python">
    <span class="{name(.)}">
      <xsl:apply-templates mode="python"/>
    </span>
  </xsl:template>

  <xsl:template match="methodparam" mode="python">
    <xsl:text>, </xsl:text>
    <span class="{name(.)}">
      <xsl:apply-templates mode="python"/>
    </span>
  </xsl:template>

  <xsl:template match="parameter" mode="python">
    <span class="{name(.)}">
      <xsl:apply-templates mode="python"/>
    </span>
  </xsl:template>

  <xsl:template match="methodsynopsis" mode="python">
    <code class="{name(.)}">
      <xsl:if test="parent::classsynopsis">
        <xsl:text>&nbsp;&nbsp;</xsl:text>
      </xsl:if>
      <xsl:text>def </xsl:text>
      <xsl:apply-templates select="methodname" mode="python"/>
      <xsl:text>(self</xsl:text>
      <xsl:apply-templates select="methodparam" mode="python"/>
      <xsl:text>)</xsl:text>
    </code>
    <xsl:call-template name="synop-break"/>
  </xsl:template>

  <xsl:template match="constructorsynopsis" mode="python">
    <code class="{name(.)}">
      <xsl:if test="parent::classsynopsis">
        <xsl:text>&nbsp;&nbsp;</xsl:text>
      </xsl:if>
      <xsl:text>def </xsl:text>
      <!-- use __init__ if methodname isn't provided -->
      <xsl:choose>
        <xsl:when test="child::methodname">
          <xsl:apply-templates select="methodname" mode="python"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>__init__</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>(self</xsl:text>
      <xsl:apply-templates select="methodparam" mode="python"/>
      <xsl:text>)</xsl:text>
    </code>
    <xsl:call-template name="synop-break"/>
  </xsl:template>

  <!-- suppress all types and modifiers -->
  <xsl:template match="void" mode="python"/>
  <xsl:template match="type" mode="python"/>
  <xsl:template match="modifier" mode="python"/>

  <!-- process links without mode="python" -->
  <xsl:template match="link|olink|xref" mode="python">
    <xsl:apply-templates select="."/>
  </xsl:template>

</xsl:stylesheet>

