

<xsl:template match="informalequation">
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

  <div class="equation">
  <table border="0" width="100%" summary="{$class}">
   <tr>
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
     <td align="{$alignment}">
      <xsl:call-template name="auto.latex.filename"/>
      <xsl:apply-templates/>
     </td>
   </tr>
  </table>
  </div>

</xsl:template>


<xsl:template match="equation">
  <xsl:param name="class" select="local-name(.)"/>
  <xsl:variable name="param.placement"
                select="substring-after(normalize-space($formal.title.placement),
                                        concat(local-name(.), ' '))"/>

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
	
  <xsl:call-template name="equations.common"/>

  <!--  xsl:choose>
    <xsl:when test="$placement = 'before'">
      <xsl:call-template name="formal.object.heading"/>
      <xsl:apply-templates/>

    </xsl:when>

    <xsl:otherwise>
      <xsl:if test="$spacing.paras != 0"><p/></xsl:if>
      <xsl:apply-templates/>

      <xsl:call-template name="formal.object.heading"/>
    </xsl:otherwise>
  </xsl:choose   -->

</xsl:template>


<xsl:template match="equation" mode="label.markup">
  <xsl:variable name="pchap"
                select="ancestor::chapter
                        |ancestor::appendix
                        |ancestor::article[ancestor::book]"/>

  <xsl:variable name="prefix">
    <xsl:if test="count($pchap) &gt; 0">
      <xsl:apply-templates select="$pchap" mode="label.markup"/>
    </xsl:if>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@label">
      <xsl:value-of select="@label"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="count($pchap)>0">
          <xsl:if test="$prefix != ''">
            <xsl:apply-templates select="$pchap" mode="label.markup"/>
            <xsl:apply-templates select="$pchap" mode="intralabel.punctuation"/>
          </xsl:if>
          <xsl:number format="1" from="chapter|appendix" level="any"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:number format="1"  from="book|article" level="any"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

