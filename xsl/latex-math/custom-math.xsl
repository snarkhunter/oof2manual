
<xsl:variable name="tex.math.in.alt">latex</xsl:variable>
<xsl:variable name="tex.math.delims">0</xsl:variable>
<xsl:variable name="spacing.paras">0</xsl:variable>
<xsl:variable name="pre.spacing.paras">0</xsl:variable>
<xsl:variable name="post.spacing.paras">0</xsl:variable>
<xsl:variable name="xref.with.number.and.title">0</xsl:variable>
<xsl:variable name="passivetex.extensions">1</xsl:variable>


<xsl:template match="inlineequation/graphic">
    <xsl:call-template name="anchor"/>
    <xsl:call-template name="process.image"/>
</xsl:template>


<!-- override the latex header for amstex -->

<xsl:template name="tex.math.latex.head">
  <xsl:text>\documentclass[leqno,11pt]{revtex4} &#xA;</xsl:text>
  <xsl:text>\usepackage{amsmath} &#xA;</xsl:text>
  <xsl:text>\usepackage{amsfonts} &#xA;</xsl:text>
  <xsl:text>\usepackage{concmath} &#xA;</xsl:text>

  <!-- xsl:text>\usepackage{amssymb} &#xA;</xsl:text -->
  <!--xsl:text>\newcommand{\operatorname}[1]{\text{#1}}&#xA;</xsl:text-->
  <xsl:text>\newcommand{\Div}{\operatorname{Div}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Grad}{\nabla}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Trace}{\operatorname{Trace}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Curl}{\operatorname{Curl}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Sum}{\sum}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Tensor}[1]{\mathbf{#1}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Vector}[1]{\mathbf{#1}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\BasisV}[1]{\mathbf{#1}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\RecipVect}[1]{\mathbf{#1}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Matrix}[1]{\mathbf{#1}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\SymOp}[1]{\mathbb{#1}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Modulus}[1]{\left|{#1}\right|}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Mean}[1]{\left&lt;{#1}\right&gt;}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Cross}{\otimes}&#xA;</xsl:text>
  <xsl:text>\newcommand{\VComp}[1]{#1}&#xA;</xsl:text><!-- vector component: tooo pedantic? -->
  <xsl:text>\newcommand{\Axis}[1]{\Vector{#1}}&#xA;</xsl:text><!-- vector component: tooo pedantic? -->
  <xsl:text>\newcommand{\Laplacian}{\Delta^{2}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\partwrt}[1]{\frac{\partial }{\partial #1 }}&#xA;</xsl:text>
  <xsl:text>\newcommand{\partTwrt}[1]{\frac{\partial T}{\partial #1 }}&#xA;</xsl:text>
  <xsl:text>\newcommand{\MatProp}[1]{\hat{#1}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\SpaProp}[1]{\tilde{#1}}&#xA;</xsl:text>
  <!--xsl:text>\newcommand{\MD}{\text{D}}&#xA;</xsl:text-->
  <xsl:text>\newcommand{\MD}{D}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Rho}{\rho}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Transpose}[1]{{#1}^{\dagger}}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Prob}[1]{\text{P}(#1)}&#xA;</xsl:text>
  <xsl:text>\newcommand{\Deriv}[1]{d{#1}}&#xA;</xsl:text>
  <xsl:text>\renewcommand{\Im}{i}&#xA;</xsl:text>
  <xsl:text>\pagestyle{empty} &#xA;</xsl:text>
  <xsl:text>\begin{document} &#xA;</xsl:text>
  <!--xsl:text>\ensuremath{\scriptstyle} &#xA;</xsl:text-->
  <xsl:text>\allowdisplaybreaks &#xA;</xsl:text>
  <!--xsl:text>\special{dvi2bitmap default foreground 255 0 0 }&#xA;</xsl:text>
  <xsl:text>\special{dvi2bitmap default background 127 127 255 }&#xA;</xsl:text-->
</xsl:template>


