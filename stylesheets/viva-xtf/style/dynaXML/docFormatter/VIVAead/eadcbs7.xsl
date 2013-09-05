<!-- EAD Cookbook Style 7      Version 0.9   19 January 2004 -->
<!--  This stylesheet generates a Table of Contents in an HTML frame along
   the left side of the screen. It is an update to eadcbs3.xsl designed
   to work with EAD 2002.-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtf="http://cdlib.org/xtf"
	xmlns="http://www.w3.org/1999/xhtml" version="1.0">

	<!-- Creates a variable equal to the value of the number in eadid which serves as the base
      for file names for the various components of the frameset.-->
	<xsl:variable name="file">
		<xsl:value-of select="ead/eadheader/eadid"/>
	</xsl:variable>

	<!--This template creates HTML meta tags that are inserted into the HTML ouput
      for use by web search engines indexing this file.   The content of each
      resulting META tag uses Dublin Core semantics and is drawn from the text of
      the finding aid.-->
	<xsl:template name="metadata">
		<meta http-equiv="Content-Type" name="dc.title"
			content="{eadheader/filedesc/titlestmt/titleproper&#x20; }{eadheader/filedesc/titlestmt/subtitle}"/>
		<meta http-equiv="Content-Type" name="dc.author" content="{archdesc/did/origination}"/>

		<xsl:for-each select="//controlaccess/persname | //controlaccess/corpname">
			<xsl:choose>
				<xsl:when test="@encodinganalog='600'">
					<meta http-equiv="Content-Type" name="dc.subject" content="{.}"/>
				</xsl:when>

				<xsl:when test="//@encodinganalog='610'">
					<meta http-equiv="Content-Type" name="dc.subject" content="{.}"/>
				</xsl:when>

				<xsl:when test="//@encodinganalog='611'">
					<meta http-equiv="Content-Type" name="dc.subject" content="{.}"/>
				</xsl:when>

				<xsl:when test="//@encodinganalog='700'">
					<meta http-equiv="Content-Type" name="dc.contributor" content="{.}"/>
				</xsl:when>

				<xsl:when test="//@encodinganalog='710'">
					<meta http-equiv="Content-Type" name="dc.contributor" content="{.}"/>
				</xsl:when>

				<xsl:otherwise>
					<meta http-equiv="Content-Type" name="dc.contributor" content="{.}"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<xsl:for-each select="//controlaccess/subject">
			<meta http-equiv="Content-Type" name="dc.subject" content="{.}"/>
		</xsl:for-each>
		<xsl:for-each select="//controlaccess/geogname">
			<meta http-equiv="Content-Type" name="dc.subject" content="{.}"/>
		</xsl:for-each>

		<meta http-equiv="Content-Type" name="dc.title" content="{archdesc/did/unittitle}"/>
		<meta http-equiv="Content-Type" name="dc.type" content="text"/>
		<meta http-equiv="Content-Type" name="dc.format" content="manuscripts"/>
		<meta http-equiv="Content-Type" name="dc.format" content="finding aids"/>

	</xsl:template>

	<!-- Creates the body of the finding aid.-->
	<xsl:template name="body">
		<xsl:variable name="file">
			<xsl:value-of select="ead/eadheader/eadid"/>
		</xsl:variable>
		<html xml:lang="en" lang="en">
			<head>

				<link rel="stylesheet" type="text/css" href="{$css.path}ead.css"/>

				<title>
					<xsl:value-of select="eadheader/filedesc/titlestmt/titleproper"/>
					<xsl:text>  </xsl:text>
					<xsl:value-of select="eadheader/filedesc/titlestmt/subtitle"/>
				</title>

				<xsl:call-template name="metadata"/>
			</head>
			<body>

				<xsl:apply-templates select="eadheader"/>

				<!--To change the order of display, adjust the sequence of
               the following apply-template statements which invoke the various
               templates that populate the finding aid.  Multiple statements
               are included to handle the possibility that descgrp has been used
               as a wrapper to replace add and admininfo.  In several cases where
               multiple elemnents are displayed together in the output, a call-template
               statement is used-->

				<xsl:apply-templates select="archdesc/did"/>

				<xsl:call-template name="archdesc-admininfo"/>
				<xsl:apply-templates select="archdesc/bioghist"/>
				<xsl:apply-templates select="archdesc/scopecontent"/>
				<xsl:apply-templates select="archdesc/arrangement"/>
				<xsl:call-template name="archdesc-relatedmaterial"/>
				<xsl:apply-templates select="archdesc/controlaccess"/>
				<xsl:apply-templates select="archdesc/odd"/>
				<xsl:apply-templates select="archdesc/originalsloc"/>
				<xsl:apply-templates select="archdesc/phystech"/>
				<xsl:apply-templates select="archdesc/descgrp[not(@type='admininfo')]"/>
				<xsl:apply-templates select="archdesc/otherfindaid | archdesc/*/otherfindaid"/>
				<xsl:apply-templates select="archdesc/fileplan | archdesc/*/fileplan"/>
				<xsl:apply-templates select="archdesc/bibliography | archdesc/*/bibliography"/>
				<xsl:apply-templates select="archdesc/index | archdesc/*/index"/>
				<xsl:apply-templates select="archdesc/dsc"/>
				<xsl:if test="//persname">
					<xsl:call-template name="persons" />
				</xsl:if>
				<xsl:if test="//geogname">
					<xsl:call-template name="places" />
				</xsl:if>
			</body>
		</html>
	</xsl:template>


	<!-- The following general templates format the display of various RENDER
      attributes.-->
	<xsl:template match="emph[@render='bold']">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='italic']">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<xsl:template match="emph[@render='underline']">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	<xsl:template match="emph[@render='sub']">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>
	<xsl:template match="emph[@render='super']">
		<super>
			<xsl:apply-templates/>
		</super>
	</xsl:template>

	<xsl:template match="emph[@render='quoted']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="emph[@render='doublequote']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	<xsl:template match="emph[@render='singlequote']">
		<xsl:text>'</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>'</xsl:text>
	</xsl:template>
	<xsl:template match="emph[@render='bolddoublequote']">
		<b>
			<xsl:text>"</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>"</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldsinglequote']">
		<b>
			<xsl:text>'</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>'</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldunderline']">
		<b>
			<u>
				<xsl:apply-templates/>
			</u>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='bolditalic']">
		<b>
			<i>
				<xsl:apply-templates/>
			</i>
		</b>
	</xsl:template>
	<xsl:template match="emph[@render='boldsmcaps']">
		<font style="font-variant: small-caps">
			<b>
				<xsl:apply-templates/>
			</b>
		</font>
	</xsl:template>
	<xsl:template match="emph[@render='smcaps']">
		<font style="font-variant: small-caps">
			<xsl:apply-templates/>
		</font>
	</xsl:template>
	<xsl:template match="title[@render='bold']">
		<b>
			<xsl:apply-templates/>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='italic']">
		<i>
			<xsl:apply-templates/>
		</i>
	</xsl:template>
	<xsl:template match="title[@render='underline']">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	<xsl:template match="title[@render='sub']">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>
	<xsl:template match="title[@render='super']">
		<super>
			<xsl:apply-templates/>
		</super>
	</xsl:template>

	<xsl:template match="title[@render='quoted']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="title[@render='doublequote']">
		<xsl:text>"</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="title[@render='singlequote']">
		<xsl:text>'</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>'</xsl:text>
	</xsl:template>
	<xsl:template match="title[@render='bolddoublequote']">
		<b>
			<xsl:text>"</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>"</xsl:text>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='boldsinglequote']">
		<b>
			<xsl:text>'</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>'</xsl:text>
		</b>
	</xsl:template>

	<xsl:template match="title[@render='boldunderline']">
		<b>
			<u>
				<xsl:apply-templates/>
			</u>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='bolditalic']">
		<b>
			<i>
				<xsl:apply-templates/>
			</i>
		</b>
	</xsl:template>
	<xsl:template match="title[@render='boldsmcaps']">
		<font style="font-variant: small-caps">
			<b>
				<xsl:apply-templates/>
			</b>
		</font>
	</xsl:template>
	<xsl:template match="title[@render='smcaps']">
		<font style="font-variant: small-caps">
			<xsl:apply-templates/>
		</font>
	</xsl:template>
	<!-- This template converts a Ref element into an HTML anchor.-->
	<xsl:template match="ref">
		<a href="#{@target}">
			<xsl:apply-templates/>
		</a>
	</xsl:template>

	<!--This template rule formats a list element anywhere
      except in arrangement.-->
	<xsl:template match="list[parent::*[not(self::arrangement)]]/head">
		<div style="margin-left: 25pt">
			<b>
				<xsl:apply-templates/>
			</b>
		</div>
	</xsl:template>

	<xsl:template match="list[parent::*[not(self::arrangement)]]/item">
		<div style="margin-left: 40pt">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<!--Formats a simple table. The width of each column is defined by the colwidth attribute in a colspec element.-->
	<xsl:template match="table">
		<table width="75%" style="margin-left: 25pt">
			<tr>
				<td colspan="3">
					<h4>
						<xsl:apply-templates select="head"/>
					</h4>
				</td>
			</tr>
			<xsl:for-each select="tgroup">
				<tr>
					<xsl:for-each select="colspec">
						<td width="{@colwidth}"/>
					</xsl:for-each>
				</tr>
				<xsl:for-each select="thead">
					<xsl:for-each select="row">
						<tr>
							<xsl:for-each select="entry">
								<td valign="top">
									<b>
										<xsl:apply-templates/>
									</b>
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</xsl:for-each>

				<xsl:for-each select="tbody">
					<xsl:for-each select="row">
						<tr>
							<xsl:for-each select="entry">
								<td valign="top">
									<xsl:apply-templates/>
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
		</table>
	</xsl:template>
	<!--This template rule formats a chronlist element.-->
	<xsl:template match="chronlist">
		<table width="100%" style="margin-left:25pt">
			<tr>
				<td width="5%"> </td>
				<td width="15%"> </td>
				<td width="80%"> </td>
			</tr>
			<xsl:apply-templates/>
		</table>
	</xsl:template>

	<xsl:template match="chronlist/head">
		<tr>
			<td colspan="3">
				<h4>
					<xsl:apply-templates/>
				</h4>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="chronlist/listhead">
		<tr>
			<td> </td>
			<td>
				<b>
					<xsl:apply-templates select="head01"/>
				</b>
			</td>
			<td>
				<b>
					<xsl:apply-templates select="head02"/>
				</b>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="chronitem">
		<!--Determine if there are event groups.-->
		<xsl:choose>
			<xsl:when test="eventgrp">
				<!--Put the date and first event on the first line.-->
				<tr>
					<td> </td>
					<td valign="top">
						<xsl:apply-templates select="date"/>
					</td>
					<td valign="top">
						<xsl:apply-templates select="eventgrp/event[position()=1]"/>
					</td>
				</tr>
				<!--Put each successive event on another line.-->
				<xsl:for-each select="eventgrp/event[not(position()=1)]">
					<tr>
						<td> </td>
						<td> </td>
						<td valign="top">
							<xsl:apply-templates select="."/>
						</td>
					</tr>
				</xsl:for-each>
			</xsl:when>
			<!--Put the date and event on a single line.-->
			<xsl:otherwise>
				<tr>
					<td> </td>
					<td valign="top">
						<xsl:apply-templates select="date"/>
					</td>
					<td valign="top">
						<xsl:apply-templates select="event"/>
					</td>
				</tr>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--Suppreses all other elements of eadheader.-->
	<xsl:template match="eadheader" >
		<xsl:apply-templates  select="/ead/frontmatter/titlepage"/>
	</xsl:template>
	
	<xsl:template match="titlepage">
		<div style="text-align:center">	
		<h2>
			<a name="top">
				<!-- <xsl:value-of select="filedesc/titlestmt/titleproper"/> 
				     note: these fields are from //frontmatter, not from //eadheader 
				     but this matches requested output format.  sdm7g -->
				<xsl:value-of select="/ead/frontmatter/titlepage/titleproper" />			
			</a>
		</h2>
		<h3>
			<xsl:apply-templates select="/ead/frontmatter/titlepage/subtitle" />
		</h3>
		<br/></div>
		<!-- insert the logo -->
		<div style="text-align:center">
			<xsl:variable name="logo" select="//node()[@id='logostmt']/extptr" />
			<xsl:variable name="logoref" >
				<xsl:choose>
					<xsl:when test="$logo/@href"><xsl:value-of select="$logo/@href"/></xsl:when>
					<xsl:when test="unparsed-entity-uri($logo/@entityref)">
						<xsl:value-of select="unparsed-entity-uri($logo/@entityref)"/>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$logoref">
					<xsl:element name="img">
						<xsl:attribute name="src">
							<xsl:value-of select="$logoref"/>
						</xsl:attribute>
						<xsl:attribute name="alt">[logo]</xsl:attribute>
						<xsl:attribute name="align">center</xsl:attribute>
						<xsl:attribute name="name">logo</xsl:attribute>
					</xsl:element>
				</xsl:when>
				<!--  otherwise just for tesing  -->
				<xsl:otherwise>[NO LOGO]</xsl:otherwise>
			</xsl:choose>
		</div>

	<!-- publisher Contact Information -->
		<div style="text-align:center" >
			<p><xsl:value-of select="publisher"/></p>
			<xsl:for-each select="list/*">
				<xsl:apply-templates  /> <br/>
			</xsl:for-each>
	<!-- Copyright & Conditions of Use -->
			<xsl:apply-templates select="/ead/eadheader/filedesc/publicationstmt/date" />
		</div>
	</xsl:template>

	<!--This template creates a table for the did, inserts the head and then
      each of the other did elements.  To change the order of appearance of these
      elements, change the sequence of the apply-templates statements.-->
	<xsl:template match="archdesc/did">
		<h3>
			<a name="{xtf:make-id(head)}">
				<xsl:apply-templates select="head"/>
			</a>
		</h3>

		<!--One can change the order of appearance for the children of did
		by changing the order of the following statements.-->
		<xsl:apply-templates select="repository"/>
		<xsl:apply-templates select="unitid"/>
		<xsl:apply-templates select="unittitle"/>
		<xsl:apply-templates select="physdesc"/>
		<xsl:apply-templates select="origination"/>
		<xsl:apply-templates select="physloc"/>
		<xsl:apply-templates select="langmaterial"/>
		<xsl:apply-templates select="materialspec"/>
		<xsl:apply-templates select="abstract"/>
		<xsl:apply-templates select="note"/>
		<hr/>
	</xsl:template>



	<!--This template formats the repostory, origination, physdesc, abstract,
      unitid, physloc and materialspec elements of archdesc/did which share a common presentaiton.
      The sequence of their appearance is governed by the previous template.-->
	<xsl:template
		match="archdesc/did/repository
      | archdesc/did/origination
      | archdesc/did/physdesc
      | archdesc/did/unitid
      | archdesc/did/physloc
      | archdesc/did/abstract
      | archdesc/did/langmaterial
      | archdesc/did/materialspec">
		<!--The template tests to see if there is a label attribute,
         inserting the contents if there is or adding display textif there isn't.
         The content of the supplied label depends on the element.  To change the
         supplied label, simply alter the template below.-->
		<div style="display:table">
			<xsl:choose>
				<xsl:when test="@label">
					<dt>
						<b>
							<xsl:value-of select="@label"/>
						</b>
					</dt>

					<dd>
						<xsl:apply-templates/>
					</dd>
				</xsl:when>
				<xsl:otherwise>

					<dt>
						<b>
							<xsl:choose>
								<xsl:when test="self::repository">
									<xsl:text>Repository</xsl:text>
								</xsl:when>
								<xsl:when test="self::origination">
									<xsl:text>Creator</xsl:text>
								</xsl:when>
								<xsl:when test="self::physdesc">
									<xsl:text>Quantity</xsl:text>
								</xsl:when>
								<xsl:when test="self::physloc">
									<xsl:text>Location</xsl:text>
								</xsl:when>
								<xsl:when test="self::unitid">
									<xsl:text>Identification</xsl:text>
								</xsl:when>
								<xsl:when test="self::langmaterial">
									<xsl:text>Language</xsl:text>
								</xsl:when>
								<xsl:when test="self::abstract">
									<xsl:text>Abstract</xsl:text>
								</xsl:when>
								<xsl:when test="self::materialspec">
									<xsl:text>Technical</xsl:text>
								</xsl:when>
							</xsl:choose>
						</b>
					</dt>
					<dd>
						<xsl:apply-templates/>
					</dd>

				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>


	<!-- The following two templates test for and processes various permutations
      of unittitle and unitdate.-->
	<xsl:template match="archdesc/did/unittitle">
		<!--The template tests to see if there is a label attribute for unittitle,
		inserting the contents if there is or adding one if there isn't. -->
		<div style="display:table">
			<xsl:choose>
				<xsl:when test="@label">
					<dt>
						<b>
							<xsl:value-of select="@label"/>
						</b>
					</dt>
					<dd>
						<!--Inserts the text of unittitle and any children other that unitdate.-->
						<xsl:apply-templates select="text() |* [not(self::unitdate)]"/>
						<xsl:if test="child::unitdate">
							<xsl:apply-templates select="unitdate"/>
						</xsl:if>
						<xsl:if test="string(parent::node()/unitdate)">
							<xsl:apply-templates select="parent::node()/unitdate"/>
						</xsl:if>
					</dd>
				</xsl:when>
				<xsl:otherwise>
					<dt>
						<b>
							<xsl:text>Title</xsl:text>
						</b>
					</dt>
					<dd>
						<xsl:apply-templates select="text() |* [not(self::unitdate)]"/>
						<xsl:if test="child::unitdate">
							<xsl:apply-templates select="unitdate"/>
						</xsl:if>
						<xsl:if test="string(parent::node()/unitdate)">
							<xsl:apply-templates select="parent::node()/unitdate"/>
						</xsl:if>
					</dd>
				</xsl:otherwise>
			</xsl:choose>
			<!--If unitdate is a child of unittitle, it inserts unitdate on a new line.  -->
		</div>
	</xsl:template>

	<!--This template processes the note element.-->
	<xsl:template match="archdesc/did/note[@audience='external']">
		<div style="display:table">
			<dt>
				<xsl:choose>
					<xsl:when test="string(normalize-space(@label))">
						<xsl:value-of select="normalize-space(@label)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Note</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</dt>
			<dd>
				<xsl:apply-templates/>
			</dd>
		</div>
	</xsl:template>

	<xsl:template match="archdesc/did/note/p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!--This template formats various head elements and makes them targets for
      links from the Table of Contents.-->
	<xsl:template
		match="archdesc/bioghist |
      archdesc/scopecontent |
      archdesc/arrangement |
      archdesc/phystech |
      archdesc/odd |
      archdesc/descgrp[not(@type='admininfo')] |
      archdesc/bioghist/note |
      archdesc/scopecontent/note |
      archdesc/phystech/note |
      archdesc/controlaccess/note |
      archdesc/odd/note">
		<div class="dd">
			<xsl:apply-templates/>
		</div>
		<hr/>
	</xsl:template>

	<xsl:template
		match="archdesc/bioghist/head  |
		archdesc/scopecontent/head |
		archdesc/arrangement/head |
		archdesc/phystech/head |
		archdesc/descgrp/head |
		archdesc/controlaccess/head |
		archdesc/odd/head |
		archdesc/arrangement/head">
		<h3 style="margin-left:-25px;">
			<a name="{xtf:make-id(.)}">
				<xsl:apply-templates/>
			</a>
		</h3>
	</xsl:template>

	<xsl:template match="p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template
		match="archdesc/bioghist/bioghist/head |
      archdesc/scopecontent/scopecontent/head">
		<h3 style="margin-left:25pt">
			<xsl:apply-templates/>
		</h3>
	</xsl:template>

	<xsl:template
		match="archdesc/bioghist/bioghist/p |
      archdesc/scopecontent/scopecontent/p |
      archdesc/bioghist/bioghist/note/p |
      archdesc/scopecontent/scopecontent/note/p">
		<p style="margin-left: 50pt">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!--This template rule formats the top-level related material
      elements by combining any related or separated materials
      elements. It begins by testing to see if there related or separated
      materials elements with content.-->
	<xsl:template name="archdesc-relatedmaterial">

		<xsl:if
			test="string(archdesc/relatedmaterial) or
         string(archdesc/*/relatedmaterial) or
         string(archdesc/separatedmaterial) or
         string(archdesc/*/separatedmaterial)">
			<div class="dd">
				<h3 style="margin-left:-25px;">
					<a name="relatedmatlink">
						<b>
							<xsl:text>Related Material</xsl:text>
						</b>
					</a>
				</h3>
				<xsl:apply-templates
					select="archdesc/relatedmaterial/p
            | archdesc/*/relatedmaterial/p
            | archdesc/relatedmaterial/note/p
            | archdesc/*/relatedmaterial/note/p"/>
				<xsl:apply-templates
					select="archdesc/separatedmaterial/p
            | archdesc/*/separatedmaterial/p
            | archdesc/separatedmaterial/note/p
            | archdesc/*/separatedmaterial/note/p"/>

			</div>
			<hr/>
		</xsl:if>

	</xsl:template>

	<xsl:template
		match="archdesc/relatedmaterial/p
      | archdesc/*/relatedmaterial/p
      | archdesc/separatedmaterial/p
      | archdesc/*/separatedmaterial/p
      | archdesc/relatedmaterial/note/p
      | archdesc/*/relatedmaterial/note/p
      | archdesc/separatedmaterial/note/p
      | archdesc/*/separatedmaterial/note/p">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!--This template formats the top-level controlaccess element.
      It begins by testing to see if there is any controlled
      access element with content. It then invokes one of two templates
      for the children of controlaccess.  -->
	<xsl:template match="archdesc/controlaccess">
		<div class="dd">
			<xsl:if test="string(child::*)">
				<a name="{xtf:make-id(head)}">
					<xsl:apply-templates select="head"/>
				</a>
				<xsl:choose>
					<!--Apply this template when there are recursive controlaccess
				elements.-->
					<xsl:when test="controlaccess">
						<ul class="index_list">
							<xsl:apply-templates mode="recursive" select="."/>
						</ul>
					</xsl:when>
					<!--Apply this template when the controlled terms are entered
               directly under the controlaccess element.-->
					<xsl:otherwise>
						<ul class="index_list">
							<xsl:apply-templates mode="direct" select="."/>
						</ul>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</div>
		<hr/>
	</xsl:template>

	<!--This template formats controlled terms that are entered
      directly under the controlaccess element.  Elements are alphabetized.-->
	<xsl:template mode="direct" match="archdesc/controlaccess">
		<xsl:for-each
			select="subject |corpname | famname | persname | genreform | title | geogname | occupation">
			<xsl:sort select="." data-type="text" order="ascending"/>
			<li>
				<xsl:apply-templates/>
			</li>
		</xsl:for-each>
	</xsl:template>

	<!--When controlled terms are nested within recursive
      controlaccess elements, the template for controlaccess/controlaccess
      is applied.-->
	<xsl:template mode="recursive" match="archdesc/controlaccess">
		<xsl:apply-templates select="controlaccess"/>
	</xsl:template>

	<!--This template formats controlled terms that are nested within recursive
      controlaccess elements.   Terms are alphabetized within each grouping.-->
	<xsl:template match="archdesc/controlaccess/controlaccess">
		<h4 style="margin-left:25pt">
			<xsl:apply-templates select="head"/>
		</h4>
		<xsl:for-each
			select="subject |corpname | famname | persname | genreform | title | geogname | occupation">
			<xsl:sort select="." data-type="text" order="ascending"/>
			<li>
				<xsl:apply-templates/>
			</li>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="archdesc-admininfo">
		<xsl:if test="archdesc/descgrp[@type='admininfo']">
			<div class="dd">
				<xsl:apply-templates select="archdesc/descgrp[@type='admininfo']"/>
			</div>
		</xsl:if>
		<xsl:if
			test="archdesc/accessrestrict | archdesc/userestrict | archdesc/prefercite | archdesc/altformavail | archdesc/accruals | archdesc/acqinfo | archdesc/appraisal | archdesc/custodhist | archdesc/processinfo">
			<xsl:if test="not(archdesc/descgrp[@type='admininfo'])">
				<h3 style="margin-left:-25px;">
					<a name="adminlink">
						<xsl:text>Administrative Information</xsl:text>
					</a>
				</h3>
			</xsl:if>
			<div class="dd">
				<xsl:apply-templates
					select="archdesc/accessrestrict | archdesc/userestrict | archdesc/prefercite | archdesc/altformavail | archdesc/accruals | archdesc/acqinfo | archdesc/appraisal | archdesc/custodhist | archdesc/processinfo"
				/>
			</div>
		</xsl:if>
		<hr/>
	</xsl:template>

	<xsl:template match="descgrp[@type='admininfo']">
		<h3 style="margin-left:-25px;">
			<a name="adminlink">
				<xsl:choose>
					<xsl:when test="head">
						<xsl:value-of select="head"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Administrative Information</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</a>
		</h3>
		<xsl:apply-templates
			select="accessrestrict | userestrict | prefercite | altformavail | accruals | acqinfo | appraisal | custodhist | processinfo"
		/>
	</xsl:template>

	<xsl:template
		match="accessrestrict | userestrict | prefercite | altformavail | accruals | acqinfo | appraisal | custodhist | processinfo">
		<xsl:apply-templates select="head | p" mode="admininfo"/>
	</xsl:template>

	<xsl:template match="head" mode="admininfo">
		<h4>
			<xsl:apply-templates/>
		</h4>
	</xsl:template>

	<xsl:template match="p" mode="admininfo">
		<p style="margin-left:25px">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<xsl:template
		match="archdesc/otherfindaid
      | archdesc/*/otherfindaid
      | archdesc/bibliography
      | archdesc/*/bibliography
      | archdesc/phystech
      | archdesc/originalsloc">
		<xsl:apply-templates/>
		<hr/>
	</xsl:template>

	<xsl:template
		match="archdesc/otherfindaid/head
      | archdesc/*/otherfindaid/head
      | archdesc/bibliography/head
      | archdesc/*/bibliography/head
      | archdesc/fileplan/head
      | archdesc/*/fileplan/head
      | archdesc/phystech/head
      | archdesc/originalsloc/head">
		<h3>
			<a name="{xtf:make-id(.)}">
				<b>
					<xsl:apply-templates/>
				</b>
			</a>
		</h3>
	</xsl:template>

	<xsl:template
		match="archdesc/otherfindaid/p
      | archdesc/*/otherfindaid/p
      | archdesc/bibliography/p
      | archdesc/*/bibliography/p
      | archdesc/otherfindaid/note/p
      | archdesc/*/otherfindaid/note/p
      | archdesc/bibliography/note/p
      | archdesc/*/bibliography/note/p
      | archdesc/fileplan/p
      | archdesc/*/fileplan/p
      | archdesc/fileplan/note/p
      | archdesc/*/fileplan/note/p
      | archdesc/phystech/p
      | archdesc/phystechc/note/p
      | archdesc/originalsloc/p
      | archdesc/originalsloc/note/p">
		<p style="margin-left:25pt">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!--This template rule tests for and formats the top-level index element. It begins
      by testing to see if there is an index element with content.-->
	<xsl:template match="archdesc/index
      | archdesc/*/index">
		<table width="100%">
			<tr>
				<td width="5%"> </td>
				<td width="45%"> </td>
				<td width="50%"> </td>
			</tr>
			<tr>
				<td colspan="3">
					<h3>
						<a name="{xtf:make-id(head)}">
							<b>
								<xsl:apply-templates select="head"/>
							</b>
						</a>
					</h3>
				</td>
			</tr>
			<xsl:for-each select="p | note/p">
				<tr>
					<td/>
					<td colspan="2">
						<xsl:apply-templates/>
					</td>
				</tr>
			</xsl:for-each>

			<!--Processes each index entry.-->
			<xsl:for-each select="indexentry">

				<!--Sorts each entry term.-->
				<xsl:sort
					select="corpname | famname | function | genreform | geogname | name | occupation | persname | subject"/>
				<tr>
					<td/>
					<td>
						<xsl:apply-templates
							select="corpname | famname | function | genreform | geogname | name | occupation | persname | subject"
						/>
					</td>
					<!--Supplies whitespace and punctuation if there is a pointer
                  group with multiple entries.-->

					<xsl:choose>
						<xsl:when test="ptrgrp">
							<td>
								<xsl:for-each select="ptrgrp">
									<xsl:for-each select="ref | ptr">
										<xsl:apply-templates/>
										<xsl:if
											test="preceding-sibling::ref or preceding-sibling::ptr">
											<xsl:text>, </xsl:text>
										</xsl:if>
									</xsl:for-each>
								</xsl:for-each>
							</td>
						</xsl:when>
						<!--If there is no pointer group, process each reference or pointer.-->
						<xsl:otherwise>
							<td>
								<xsl:for-each select="ref | ptr">
									<xsl:apply-templates/>
								</xsl:for-each>
							</td>
						</xsl:otherwise>
					</xsl:choose>
				</tr>
				<!--Closes the indexentry.-->
			</xsl:for-each>
		</table>
		<hr/>
	</xsl:template>

	<xsl:template match="dao | daoloc">
		<xsl:if test="contains(@href, '.jpg')">
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="string(normalize-space(@title))">
						<xsl:value-of select="@title"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="substring-after(substring-before(@href, '.jpg'), 'tj/')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<a href="{@href}" title="{$title}" class="jqueryLightbox">
				<xsl:value-of select="$title"/>
			</a>
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="lb">
		<br/>
	</xsl:template>


	<xsl:template match="extref[@href]" >
		<xsl:element name="a" >
			<xsl:attribute name="href" >
				<xsl:value-of select="@href"/>
			</xsl:attribute>
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>


	<xsl:template match="subtitle/num">
		<br/>
		<xsl:value-of select="@type"/><xsl:text> </xsl:text>
		<xsl:apply-templates/><br />
	</xsl:template>

	<xsl:template name="persons">
		<xsl:if test="//persname" >
		<div class="people" >
			<h3 ><a name="people">Significant Persons Associated With the Collection</a></h3>
			<ul>
				<xsl:for-each select="distinct-values(//persname)">
					<xsl:sort/>
					<li>
						<xsl:value-of select="."/>
					</li>
				</xsl:for-each>
			</ul>	
			<div class="backtotop">
				<a href="#top" target="_self">Back to Top</a>
			</div>
		</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="places">
		<xsl:if test="//geogname" >
		<div class="places" >
			<h3 ><a name="places">Significant Places Associated With the Collection</a></h3>
			<ul>
				<xsl:for-each select="distinct-values(//geogname)">
					<xsl:sort/>
					<li>
						<xsl:value-of select="."/>
					</li>
				</xsl:for-each>
			</ul>
			<div class="backtotop">
				<a href="#top" target="_self">Back to Top</a>
			</div>
		</div>
		</xsl:if>
	</xsl:template>


	<!--Insert the address for the dsc stylesheet of your choice here.-->
	<xsl:include href="dsc4.xsl"/>
</xsl:stylesheet>
