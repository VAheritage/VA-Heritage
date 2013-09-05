<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xtf="http://cdlib.org/xtf" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:session="java:org.cdlib.xtf.xslt.Session" extension-element-prefixes="session"
	exclude-result-prefixes="#all">

  <!--  import the standard XTF common stylesheet 
         and override with custom templates here. 
  -->

	<xsl:import href="../common/docFormatterCommon.xsl"/>

	<!-- ====================================================================== -->
	<!-- Button Bar Templates                                                   -->
	<!-- ====================================================================== -->

	<xsl:template name="bbar">
		<link rel="stylesheet" type="text/css" href="{$css.path}bbar.css"/>
		<div class="bbar">
			<xsl:copy-of select="$brand.header"/>
			<div class="menu_container">
				<ul class="menu">
					<li class="tab">
						<a href="search?smode=simple">Basic Search</a>
					</li>
					<li class="tab">
						<a href="search?smode=advanced">Advanced Search</a>
					</li>
					<li class="tab">
						<a href="search?browse-all=yes">Browse</a>
					</li>
				</ul>
				<div class="right">
					<a>
						<xsl:attribute name="href">javascript://</xsl:attribute>
						<xsl:attribute name="onclick">
							<xsl:text>javascript:window.open('</xsl:text>
							<xsl:value-of select="$xtfURL"/>
							<xsl:value-of select="$dynaxmlPath"/>
							<xsl:text>?docId=</xsl:text>
							<xsl:value-of select="$docId"/>
							<xsl:text>;doc.view=citation</xsl:text>
							<xsl:text>','popup','width=800,height=400,resizable=yes,scrollbars=no')</xsl:text>
						</xsl:attribute>
						<xsl:text>Citation</xsl:text>
					</a>
					<xsl:text> | </xsl:text>
					<a href="{$doc.path}&#038;doc.view=print;chunk.id={$chunk.id}" target="_top"
						>Print View</a>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
