<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xtf="http://cdlib.org/xtf" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:session="java:org.cdlib.xtf.xslt.Session" extension-element-prefixes="session"
	exclude-result-prefixes="#all">

	<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- VIVAEAD dynaXML Stylesheet                                                 -->
	<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

	<!--
      Copyright (c) 2008, Regents of the University of California
      All rights reserved.
      
      Redistribution and use in source and binary forms, with or without 
      modification, are permitted provided that the following conditions are 
      met:
      
      - Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
      - Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in the 
      documentation and/or other materials provided with the distribution.
      - Neither the name of the University of California nor the names of its
      contributors may be used to endorse or promote products derived from 
      this software without specific prior written permission.
      
      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
      AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
      IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
      ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
      LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
      CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
      SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
      INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
      CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
      ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
      POSSIBILITY OF SUCH DAMAGE.
   -->

	<!-- 
      NOTE: This is rough adaptation of the EAD Cookbook stylesheets to get them 
      to work with XTF. It should in no way be considered a production interface 
   -->

	<!-- ====================================================================== -->
	<!-- Import Common Templates                                                -->
	<!-- ====================================================================== -->

	<xsl:import href="docFormatterCommon.xsl"/>

	<!-- ====================================================================== -->
	<!-- Output Format                                                          -->
	<!-- ====================================================================== -->

	<xsl:output method="xhtml" indent="yes" encoding="UTF-8" media-type="text/html; charset=UTF-8"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		exclude-result-prefixes="#all" omit-xml-declaration="yes"/>

	<xsl:output name="frameset" method="xhtml" indent="no" encoding="UTF-8"
		media-type="text/html; charset=UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Frameset//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"
		omit-xml-declaration="yes" exclude-result-prefixes="#all"/>

	<!-- ====================================================================== -->
	<!-- Strip Space                                                            -->
	<!-- ====================================================================== -->

	<xsl:strip-space elements="*"/>

	<!-- ====================================================================== -->
	<!-- Included Stylesheets                                                   -->
	<!-- ====================================================================== -->

	<xsl:include href="eadcbs7.xsl"/>
	<xsl:include href="parameter.xsl"/>
	<xsl:include href="search.xsl"/>

	<!-- ====================================================================== -->
	<!-- Root Template                                                          -->
	<!-- ====================================================================== -->

	<xsl:template match="/ead">
		<xsl:choose>
			<!-- robot solution -->
			<xsl:when test="matches($http.user-agent,$robots)">
				<xsl:call-template name="robot"/>
			</xsl:when>
			<!-- print view -->
			<xsl:when test="$doc.view='print'">
				<xsl:call-template name="print"/>
			</xsl:when>
			<!-- citation -->
			<xsl:when test="$doc.view='citation'">
				<xsl:call-template name="citation"/>
			</xsl:when>
			<xsl:when test="$doc.view='content'">
				<xsl:call-template name="body" /> <!-- for testing and profiling only -->
			</xsl:when>
			<!-- Creates the basic frameset.-->
			<xsl:otherwise>
				<xsl:call-template name="generate_content"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Frameset Template                                                      -->
	<!-- ====================================================================== -->

	<xsl:template name="generate_content">
		<html xml:lang="en" lang="en">
			<head>
				<xsl:copy-of select="$brand.links" />
				<title>
					<xsl:value-of select="eadheader/filedesc/titlestmt/titleproper"/>
					<xsl:text>  </xsl:text>
					<xsl:value-of select="eadheader/filedesc/titlestmt/subtitle"/>
				</title>
			</head>

			<body>
				<div class="page_content">
					<xsl:call-template name="bbar"/>
					<div class="wrap">
						<xsl:call-template name="toc"/>
						<div class="content">
							<xsl:call-template name="body"/>
						</div>
					</div>
				</div>
				<xsl:copy-of select="$brand.footer"/>
			</body>
		</html>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Anchor Template                                                        -->
	<!-- ====================================================================== -->

	<xsl:template name="create.anchor">
		<xsl:choose>
			<xsl:when test="($query != '0' and $query != '') and $hit.rank != '0'">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="key('hit-rank-dynamic', $hit.rank)/@hitNum"/>
			</xsl:when>
			<xsl:when test="($query != '0' and $query != '') and $set.anchor != '0'">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="$set.anchor"/>
			</xsl:when>
			<xsl:when test="$query != '0' and $query != ''">
				<xsl:text>#</xsl:text>
				<xsl:value-of select="/*/@xtf:firstHit"/>
			</xsl:when>
			<xsl:when test="$anchor.id != '0'">
				<xsl:text>#X</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- TOC Templates                                                          -->
	<!-- ====================================================================== -->

	<xsl:template name="toc">
		<xsl:variable name="sum">
			<xsl:choose>
				<xsl:when test="($query != '0') and ($query != '')">
					<xsl:value-of select="number(/*[1]/@xtf:hitCount)"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="occur">
			<xsl:choose>
				<xsl:when test="$sum != 1">occurrences</xsl:when>
				<xsl:otherwise>occurrence</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="toc">
			<div class="search_div">
				<div style="font-weight:bold;text-transform:uppercase;letter-spacing:3px;">Search
					Finding Aid</div>
				<form action="{$xtfURL}{$dynaxmlPath}" method="get">
					<input name="query" type="text" size="15" class="search_form"/>
					<input type="hidden" name="docId" value="{$docId}"/>
					<input type="hidden" name="chunk.id" value="{$chunk.id}"/>
					<input type="submit" value="Go" class="button"/>
				</form>
			</div>
			<xsl:if test="($query != '0') and ($query != '')">
				<div class="search_results_div">
					<b>
						<span class="hit-count">
							<xsl:value-of select="$sum"/>
						</span>
						<xsl:text> </xsl:text>
						<xsl:value-of select="$occur"/>
						<xsl:text> of </xsl:text>
						<span class="hit-count">
							<xsl:value-of select="$query"/>
							<a href="#1">
								<img src="{$icon.path}b_innext.gif" border="0" alt="next hit" style="margin-left:10px;"/>
							</a>
						</span>
					</b>
					<br/>
					<xsl:text> [</xsl:text>
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="$doc.path"/>&#038;chunk.id=<xsl:value-of
								select="$chunk.id"/>&#038;toc.depth=<xsl:value-of
								select="$toc.depth"/>&#038;toc.id=<xsl:value-of select="$toc.id"
								/>&#038;brand=<xsl:value-of select="$brand"/>
						</xsl:attribute>
						<xsl:text>Clear Hits</xsl:text>
					</a>
					<xsl:text>]</xsl:text>
				</div>
			</xsl:if>
			<!-- The Table of Contents template performs a series of tests to
                  determine which elements will be included in the table
                  of contents.  Each if statement tests to see if there is
                  a matching element with content in the finding aid.-->

			<ul class="toc_ul">
				<xsl:if test="archdesc/did/head">
					<xsl:apply-templates select="archdesc/did/head" mode="tocLink"/>
				</xsl:if>
				<xsl:if
					test="archdesc/accessrestrict or archdesc/userestrict or archdesc/prefercite or archdesc/altformavail or archdesc/accruals or archdesc/acqinfo or archdesc/appraisal or archdesc/custodhist or archdesc/processinfo or archdesc/descgrp[@type='admininfo']">
					<xsl:call-template name="make-toc-link">
						<xsl:with-param name="name" select="'Administrative Information'"/>
						<xsl:with-param name="id" select="'adminlink'"/>
						<xsl:with-param name="nodes"
							select="archdesc/acqinfo|archdesc/prefercite|archdesc/custodialhist|archdesc/custodialhist|archdesc/processinfo|archdesc/appraisal|archdesc/accruals|archdesc/*/acqinfo|archdesc/*/processinfo|archdesc/*/prefercite|archdesc/*/custodialhist|archdesc/*/procinfo|archdesc/*/appraisal|archdesc/*/accruals/*"
						/>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="archdesc/bioghist/head">
					<xsl:apply-templates select="archdesc/bioghist/head" mode="tocLink"/>
				</xsl:if>
				<xsl:if test="archdesc/scopecontent/head">
					<xsl:apply-templates select="archdesc/scopecontent/head" mode="tocLink"/>
				</xsl:if>
				<xsl:if test="archdesc/arrangement/head">
					<xsl:apply-templates select="archdesc/arrangement/head" mode="tocLink"/>
				</xsl:if>

				<xsl:if test="archdesc/controlaccess/head">
					<xsl:apply-templates select="archdesc/controlaccess/head" mode="tocLink"/>
				</xsl:if>
				<xsl:if
					test="archdesc/relatedmaterial   or archdesc/separatedmaterial   or archdesc/*/relatedmaterial   or archdesc/*/separatedmaterial">
					<xsl:call-template name="make-toc-link">
						<xsl:with-param name="name" select="'Related Material'"/>
						<xsl:with-param name="id" select="'relatedmatlink'"/>
						<xsl:with-param name="nodes"
							select="archdesc/relatedmaterial|archdesc/separatedmaterial|archdesc/*/relatedmaterial|archdesc/*/separatedmaterial"
						/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="archdesc/otherfindaid/head    or archdesc/*/otherfindaid/head">
					<xsl:choose>
						<xsl:when test="archdesc/otherfindaid/head">
							<xsl:apply-templates select="archdesc/otherfindaid/head" mode="tocLink"
							/>
						</xsl:when>
						<xsl:when test="archdesc/*/otherfindaid/head">
							<xsl:apply-templates select="archdesc/*/otherfindaid/head"
								mode="tocLink"/>
						</xsl:when>
					</xsl:choose>
				</xsl:if>

				<!--The next test covers the situation where there is more than one odd element
                  in the document.-->
				<xsl:if test="archdesc/odd/head">
					<xsl:for-each select="archdesc/odd">
						<xsl:call-template name="make-toc-link">
							<xsl:with-param name="name" select="head"/>
							<xsl:with-param name="id" select="xtf:make-id(head)"/>
							<xsl:with-param name="nodes" select="."/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>

				<xsl:if test="archdesc/bibliography/head    or archdesc/*/bibliography/head">
					<xsl:choose>
						<xsl:when test="archdesc/bibliography/head">
							<xsl:apply-templates select="archdesc/bibliography/head" mode="tocLink"
							/>
						</xsl:when>
						<xsl:when test="archdesc/*/bibliography/head">
							<xsl:apply-templates select="archdesc/*/bibliography/head"
								mode="tocLink"/>
						</xsl:when>
					</xsl:choose>
				</xsl:if>

				<xsl:if test="archdesc/index/head    or archdesc/*/index/head">
					<xsl:choose>
						<xsl:when test="archdesc/index/head">
							<xsl:apply-templates select="archdesc/index/head" mode="tocLink"/>
						</xsl:when>
						<xsl:when test="archdesc/*/index/head">
							<xsl:apply-templates select="archdesc/*/index/head" mode="tocLink"/>
						</xsl:when>
					</xsl:choose>
				</xsl:if>

				<xsl:if test="archdesc/descgrp[not(@type='admininfo')]/head">
					<xsl:apply-templates select="archdesc/descgrp[not(@type='admininfo')]/head"
						mode="tocLink"/>
				</xsl:if>
				<!--End of the table of contents. -->
				<xsl:if test="archdesc/dsc/head">
					<li>
						<div class="toc_link">
							<a href="#{xtf:make-id(archdesc/dsc/head)}" target="_self">
								<xsl:value-of select="archdesc/dsc/head"/>
							</a>


							<xsl:for-each
								select="archdesc/dsc/c01[@level='series' or @level='subseries' or @level='subgrp' or @level='subcollection']">
								<ul class="c">
									<xsl:call-template name="make-toc-link">
										<xsl:with-param name="name">
											<xsl:choose>
												<xsl:when test="0"> <!-- sdm7g: disable this branch test="did/unittitle/unitdate" -->
												<xsl:for-each select="did/unittitle">
												<xsl:value-of select="text()"/>
												<xsl:text> </xsl:text>
												<xsl:apply-templates select="./unitdate"/>
												</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
												<xsl:apply-templates select="did/unittitle"/>
												<xsl:text> </xsl:text>
												<xsl:apply-templates select="did/unitdate"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:with-param>
										<xsl:with-param name="id">
											<xsl:value-of select="concat('series', position())"/>
										</xsl:with-param>
										<xsl:with-param name="nodes" select="."/>
										<xsl:with-param name="indent" select="2"/>
									</xsl:call-template>

									<!-- display c02 subseries links -->
									<xsl:if test="c02[@level='subseries']">
										<ul class="c">
											<xsl:apply-templates select="c02[@level='subseries']"
												mode="toc"/>
										</ul>
									</xsl:if>
								</ul>
							</xsl:for-each>
						</div>
					</li>
				</xsl:if>
				
				<xsl:if test="//persname" >
					<xsl:call-template name="make-toc-link">
						<xsl:with-param name="id">people</xsl:with-param>
						<xsl:with-param name="name">people</xsl:with-param>
					</xsl:call-template>	
				</xsl:if>

				<xsl:if test="//geogname" >
					<xsl:call-template name="make-toc-link">
						<xsl:with-param name="id">places</xsl:with-param>
						<xsl:with-param name="name">places</xsl:with-param>
					</xsl:call-template>
					
				</xsl:if>

			</ul>
		</div>
	</xsl:template>

	<xsl:template match="c02[@level='subseries']" mode="toc">
		<xsl:call-template name="make-toc-link">
			<xsl:with-param name="name">
				<xsl:choose>
					<xsl:when test="did/unittitle">
						<xsl:choose>
							<xsl:when test="0"> <!-- sdm7g: disable this branch test="did/unittitle/unitdate" -->
								<xsl:for-each select="did/unittitle">
									<xsl:value-of select="text()"/>
									<xsl:text> </xsl:text>
									<xsl:apply-templates select="./unitdate"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="did/unittitle"/>
								<xsl:text> </xsl:text>
								<xsl:apply-templates select="did/unitdate"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="did/container/@label"/>
						<xsl:text> </xsl:text>
						<xsl:value-of select="did/container"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="id">
				<!-- here -->
				<xsl:value-of
					select="concat('subseries', count(preceding::c02[@level='subseries'])+1)"/>
			</xsl:with-param>
			<xsl:with-param name="nodes" select="."/>
			<xsl:with-param name="indent" select="3"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="node()" mode="tocLink">
		<xsl:call-template name="make-toc-link">
			<xsl:with-param name="name" select="string(.)"/>
			<xsl:with-param name="id" select="xtf:make-id(.)"/>
			<xsl:with-param name="nodes" select="parent::*"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="make-toc-link">
		<xsl:param name="name"/>
		<xsl:param name="id"/>
		<xsl:param name="nodes"/>
		<xsl:param name="indent" select="1"/>

		<xsl:variable name="hit.count" select="sum($nodes/*/@xtf:hitCount)"/>
		<xsl:choose>
			<xsl:when test="not(contains($id, 'series')) and not(contains($id, 'subseries'))">
				<li>
					<div class="toc_link">
						<a href="#{$id}" target="_self">
							<xsl:value-of select="translate($name,'/',' ')"/>
						</a>
					</div>
				</li>
			</xsl:when>
			<xsl:when test="contains($id, 'series') or contains($id, 'subseries')">
				<li>
					<div class="toc_link_c">
						<a href="#{$id}">
							<xsl:value-of select="$name"/>
						</a>
					</div>
				</li>
			</xsl:when>
		</xsl:choose>


	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Print Template                                                         -->
	<!-- ====================================================================== -->

	<xsl:template name="print">
		<html xml:lang="en" lang="en">
			<head>
				<title>
					<xsl:value-of select="$doc.title"/>
				</title>
			</head>
			<body>
				<xsl:call-template name="body"/>
			</body>
		</html>
	</xsl:template>
	
	
	<!-- ====================================================================== -->
	<!-- Citation Template   - specialized EAD version modified from the template
	      in common/docFormatterCommon.xsl : use <prefercite> is possible -->
	<!-- ====================================================================== -->
	
	<xsl:template name="citation">
		
		<html xml:lang="en" lang="en">
			<head>
				<title>
					<xsl:value-of select="$doc.title"/>
				</title>
				<link rel="stylesheet" type="text/css" href="{$css.path}bbar.css"/>
				<link rel="shortcut icon" href="icons/default/favicon.ico" />
				
			</head>
			<body>
				<xsl:copy-of select="$brand.header"/>
				<div class="container">
					<h2>Citation</h2>
					<div class="citation">
						<xsl:choose>
							<xsl:when test="/ead/archdesc/descgrp/prefercite[not (contains(.,'EDIT ME'))]">
								<p>
									<xsl:copy-of select="/ead/archdesc/descgrp/prefercite"/>
								</p>	
							</xsl:when>
							<xsl:otherwise>
								<p>
									<xsl:value-of select="/*/*:meta/*:title[1]"/>. <br/>
								
									<xsl:value-of select="/*/*:meta/*:facet-publisher[1]" />.
									<xsl:value-of select="/*/*:meta/*:year[1]"/>.<br/>
									</p>
							</xsl:otherwise>
						</xsl:choose>
						<p>
						[<xsl:value-of select="concat($xtfURL,$dynaxmlPath,'?docId=',$docId)"/>]
						</p>
						<a>
							<xsl:attribute name="href">javascript://</xsl:attribute>
							<xsl:attribute name="onClick">
								<xsl:text>javascript:window.close('popup')</xsl:text>
							</xsl:attribute>
							<span class="down1">Close this Window</span>
						</a>
					</div>
				</div>
			</body>
		</html>
		
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Functions                                                              -->
	<!-- ====================================================================== -->

	<xsl:function name="xtf:make-id">
		<xsl:param name="node"/>
		<xsl:choose>
			<xsl:when test="$node/@id">
				<xsl:value-of select="$node/@id"/>
			</xsl:when>
			<xsl:when test="$node">
				<xsl:value-of
					select="concat(xtf:make-id($node/parent::*), '.', count($node/preceding-sibling::*) + 1)"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>node</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
