<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:session="java:org.cdlib.xtf.xslt.Session" xmlns:editURL="http://cdlib.org/xtf/editURL"
	xmlns="http://www.w3.org/1999/xhtml" extension-element-prefixes="session"
	exclude-result-prefixes="#all" version="2.0">

	<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- Query result formatter stylesheet                                      -->
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

	<!-- this stylesheet implements very simple search forms and query results. 
      Alpha and facet browsing are also included. Formatting has been kept to a 
      minimum to make the stylesheets easily adaptable. -->

	<!-- ====================================================================== -->
	<!-- Import Common Templates                                                -->
	<!-- ====================================================================== -->

	<xsl:import href="../common/resultFormatterCommon.xsl"/>
	<xsl:include href="searchForms.xsl"/>

	<!-- ====================================================================== -->
	<!-- Output                                                                 -->
	<!-- ====================================================================== -->

	<xsl:output method="xhtml" indent="no" encoding="UTF-8" media-type="text/html; charset=UTF-8"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
		omit-xml-declaration="yes" exclude-result-prefixes="#all"/>

	<!-- ====================================================================== -->
	<!-- Local Parameters                                                       -->
	<!-- ====================================================================== -->

	<xsl:param name="css.path" select="concat($xtfURL, 'css/viva/')"/>
	<xsl:param name="icon.path" select="concat($xtfURL, 'icons/default/')"/>
	<xsl:param name="docHits" select="/crossQueryResult/docHit"/>
	<xsl:param name="email"/>
	<xsl:param name="browse-all"/>
	
	<xsl:param name="http.URL"/>
	

	<!-- ====================================================================== -->
	<!-- Root Template                                                          -->
	<!-- ====================================================================== -->

	<xsl:template match="/" exclude-result-prefixes="#all">
		<xsl:message>========= resultFormatter.xsl [ROOT] ========</xsl:message>
		<xsl:choose>
			<!-- robot response -->
			<xsl:when test="matches($http.user-agent,$robots)">
				<xsl:apply-templates select="crossQueryResult" mode="robot"/>
			</xsl:when>
			<xsl:when test="$smode = 'showBag'">
				<xsl:apply-templates select="crossQueryResult" mode="results"/>
			</xsl:when>
			<!-- book bag -->
			<xsl:when test="$smode = 'addToBag'">
				<span>Added</span>
			</xsl:when>
			<xsl:when test="$smode = 'removeFromBag'">
				<!-- no output needed -->
			</xsl:when>
			<xsl:when test="$smode='getAddress'">
				<xsl:call-template name="getAddress"/>
			</xsl:when>
			<xsl:when test="$smode='emailFolder'">
				<xsl:apply-templates select="crossQueryResult" mode="emailFolder"/>
			</xsl:when>
			<!-- similar item -->
			<xsl:when test="$smode = 'moreLike'">
				<xsl:apply-templates select="crossQueryResult" mode="moreLike"/>
			</xsl:when>
			<!-- modify search -->
			<xsl:when test="contains($smode, '-modify')">
				<xsl:apply-templates select="crossQueryResult" mode="form"/>
			</xsl:when>
			<!-- browse pages -->
			<xsl:when test="$browse-title or $browse-creator">
				<xsl:message>mode=browse select=crossQueryResult</xsl:message>
				<xsl:apply-templates select="crossQueryResult" mode="browse"/>
			</xsl:when>
			<!-- show results -->
			<xsl:when test="crossQueryResult/query/*/*">
				<xsl:message>mode=results select=crossQueryResult</xsl:message>				
				<xsl:apply-templates select="crossQueryResult" mode="results"/>
			</xsl:when>
			<!-- show form -->
			<xsl:otherwise>
				<xsl:message>mode=form select=crossQueryResult</xsl:message>
				<xsl:apply-templates select="crossQueryResult" mode="form"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Results Template                                                       -->
	<!-- ====================================================================== -->

	<xsl:template match="crossQueryResult" mode="results" exclude-result-prefixes="#all">



		<!-- modify query URL -->
		<xsl:variable name="modify"
			select="if(matches($smode,'simple')) then 'simple-modify' else 'advanced-modify'"/>
		<xsl:variable name="modifyString" select="editURL:set($queryString, 'smode', $modify)"/>

		<html xml:lang="en" lang="en">
			<head>
				<title>XTF: Search Results</title>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<xsl:copy-of select="$brand.links"/>
				<!-- AJAX support -->
				<script src="script/viva/params.js" type="text/javascript"/>
				<script src="script/viva/sort.js" type="text/javascript"/>
			</head>
			<body>
				<div class="page_content">
					<!-- header -->
					<xsl:copy-of select="$brand.header"/>
					<!--<xsl:if test="$smode != 'showBag'">
									<xsl:variable name="bag" select="session:getData('bag')"/>
									<a href="{$xtfURL}{$crossqueryPath}?smode=showBag">Bookbag</a>
										(<span id="bagCount">
										<xsl:value-of select="count($bag/bag/savedDoc)"/>
									</span>) </xsl:if>-->


					<!--<xsl:choose>
								<xsl:when test="$smode='showBag'">
									<a>
										<xsl:attribute name="href">javascript://</xsl:attribute>
										<xsl:attribute name="onclick">
											<xsl:text>javascript:window.open('</xsl:text><xsl:value-of
												select="$xtfURL"
											/>search?smode=getAddress<xsl:text>','popup','width=500,height=200,resizable=no,scrollbars=no')</xsl:text>
										</xsl:attribute>
										<xsl:text>E-mail My Bookbag</xsl:text>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<div class="query">
										<div class="label">
											<b><xsl:value-of
												select="if($browse-all) then 'Browse by' else 'Search'"
												/>:</b>
										</div>
										<xsl:call-template name="format-query"/>
									</div>
								</xsl:otherwise>
							</xsl:choose>-->


					<xsl:call-template name="menu_container" />



					<xsl:if test="docHit">
						<div class="paging_container">
							<div style="padding-left:10px;padding-right:10px;">
								<xsl:if test="docHit">
									<div class="results_container">
										<div style="float:left;">
											<span
												style="font-weight:bold;text-transform:uppercase;letter-spacing:3px;text-align:center;width:100%;font-size:16px;margin-right:40px;">
												<xsl:variable name="items" select="@totalDocs"/>

												<xsl:if test="$items &gt; 20">
												<xsl:value-of select="$startDoc"/>
												<xsl:text> to </xsl:text>
												<xsl:choose>
												<xsl:when
												test="$items &gt; ($startDoc + 19)">
												<xsl:value-of
												select="number($startDoc + 19)"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="$items"/>
												</xsl:otherwise>
												</xsl:choose>
												<xsl:text> of </xsl:text>
												</xsl:if>
												<xsl:value-of select="$items"/>
												<xsl:choose>
												<xsl:when test="$items = 1">
												<xsl:text> Finding Aid.</xsl:text>
												</xsl:when>
												<xsl:otherwise>
												<xsl:text> Finding Aids.</xsl:text>
												</xsl:otherwise>
												</xsl:choose>
											</span>
											<form method="get" action="{$xtfURL}{$crossqueryPath}"
												class="sort">
												<b>Sort by: </b>
												<xsl:call-template name="hidden.query">
												<xsl:with-param name="queryString"
												select="$queryString"/>													
												</xsl:call-template>
												<xsl:call-template name="sort.options"/>
												<input type="submit" value="Go" class="button" id="sort_button"/>
											</form>
										</div>
										<xsl:if test="//spelling">
											<div style="float:left;padding-left:20px;">
												<xsl:call-template name="did-you-mean">
												<xsl:with-param name="baseURL"
												select="concat($xtfURL, $crossqueryPath, '?', $queryString)"/>
												<xsl:with-param name="spelling"
												select="//spelling"/>
												</xsl:call-template>
											</div>
										</xsl:if>
										<div style="float:right;text-align:right;">
											<xsl:call-template name="paging"/>
										</div>
									</div>
								</xsl:if>
								<div class="paging_divider"/>
							</div>
						</div>
					</xsl:if>

					<!-- results -->
					<xsl:choose>
						<xsl:when test="docHit">
							<div class="results">
								<xsl:if test="not($smode='showBag')">
									<div class="facet_column">
										<div class="term_div">
											<div
												style="font-weight:bold;text-transform:uppercase;letter-spacing:3px;text-align:center;width:100%;"
												>Terms</div>
											<xsl:call-template name="format-query"/>
										</div>
										<div class="search_div">
											<div
												style="font-weight:bold;text-transform:uppercase;letter-spacing:3px;"
												>Search</div>
											<form action="{$http.URL}" method="get"
												id="form">
												<input type="text" size="8" class="search_form"
												name="text"/>
												<xsl:call-template name="hidden.query" >
													<xsl:with-param name="queryString" select="$queryString" />
												</xsl:call-template>
												<select class="dropdown" id="dropdown">
												<option value="" title="within">Within Results</option>
												<option value="" title="new" disabled="true" >New Search</option>
												</select>
												<input type="submit" value="Go" class="button"
												id="search_within"/>
											</form>
										</div>
										<div class="facet_header">Limit by Facet</div>
										<xsl:if test="facet[@field='facet-subject']">
											<xsl:apply-templates
												select="facet[@field='facet-subject']"/>
										</xsl:if>
										<xsl:apply-templates
											select="facet[@field='facet-publisher']"/>
										<xsl:apply-templates select="facet[@field='facet-date']"/>
									</div>
								</xsl:if>
								<div class="docHit_column">
									<xsl:apply-templates select="docHit"/>
								</div>
								<div class="bottom_paging">
									<div style="padding:10px;">
										<xsl:call-template name="paging"/>
									</div>
								</div>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="searchPage">
								<xsl:choose>
									<xsl:when test="$smode = 'showBag'">
										<p>Your Bookbag is empty.</p>
										<p>Click on the 'Add' link next to one or more items in your
												<a href="{session:getData('queryURL')}">Search
												Results</a>.</p>
									</xsl:when>
									<xsl:otherwise>
										<div class="form">
											<p>Sorry, no results...</p>
											<p>Try modifying your search:</p>
											<xsl:choose>
												<xsl:when test="matches($smode,'advanced')">
												<xsl:call-template name="advancedForm"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:call-template name="simpleForm"/>
												</xsl:otherwise>
											</xsl:choose>
										</div>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>

				<!-- footer -->
				<xsl:copy-of select="$brand.footer"/>

			</body>
		</html>
	</xsl:template>

	<!-- PAGING -->

	<xsl:template name="paging">
		<!--<b><xsl:value-of
				select="if($smode='showBag') then 'Bookbag' else 'Results'"
				/>:</b>
				<xsl:text> </xsl:text>-->
		<xsl:call-template name="pages"/>
	</xsl:template>


	<!-- ====================================================================== -->
	<!-- Bookbag Templates                                                      -->
	<!-- ====================================================================== -->

	<xsl:template name="getAddress" exclude-result-prefixes="#all">
		<html xml:lang="en" lang="en">
			<head>
				<title>E-mail My Bookbag: Get Address</title>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<xsl:copy-of select="$brand.links"/>
			</head>
			<body>
				<xsl:copy-of select="$brand.header"/>
				<div class="getAddress">
					<h2>E-mail My Bookbag</h2>
					<form action="{$xtfURL}{$crossqueryPath}" method="get">
						<xsl:text>Address: </xsl:text>
						<input type="text" name="email"/>
						<xsl:text>&#160;</xsl:text>
						<input type="reset" value="CLEAR"/>
						<xsl:text>&#160;</xsl:text>
						<input type="submit" value="SUBMIT"/>
						<input type="hidden" name="smode" value="emailFolder"/>
					</form>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="crossQueryResult" mode="emailFolder" exclude-result-prefixes="#all">

		<xsl:variable name="bookbagContents" select="session:getData('bag')/bag"/>

		<!-- Change the values for @smtpHost and @from to those valid for your domain 
		<mail:send xmlns:mail="java:/org.cdlib.xtf.saxonExt.Mail"
			xsl:extension-element-prefixes="mail" smtpHost="smtp.yourserver.org" useSSL="no"
			from="admin@yourserver.org" to="{$email}" subject="XTF: My Bookbag"> Your XTF Bookbag:
				<xsl:apply-templates select="$bookbagContents/savedDoc" mode="emailFolder"/>
				</mail:send> -->

		<html xml:lang="en" lang="en">
			<head>
				<title>E-mail My Citations: Success</title>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<xsl:copy-of select="$brand.links"/>
			</head>
			<body onload="autoCloseTimer = setTimeout('window.close()', 1000)">
				<xsl:copy-of select="$brand.header"/>
				<h1>E-mail My Citations</h1>
				<b>Your citations have been sent.</b>
			</body>
		</html>

	</xsl:template>

	<xsl:template match="savedDoc" mode="emailFolder" exclude-result-prefixes="#all">
		<xsl:variable name="num" select="position()"/>
		<xsl:variable name="id" select="@id"/>
		<xsl:for-each select="$docHits[string(meta/identifier[1]) = $id][1]">
			<xsl:variable name="path" select="@path"/>
			<xsl:variable name="url">
				<xsl:value-of select="$xtfURL"/>
				<xsl:choose>
					<xsl:when test="matches(meta/display, 'dynaxml')">
						<xsl:call-template name="dynaxml.url">
							<xsl:with-param name="path" select="$path"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="rawDisplay.url">
							<xsl:with-param name="path" select="$path"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable> Item number <xsl:value-of select="$num"/>: <xsl:value-of
				select="meta/creator"/>. <xsl:value-of select="meta/title"/>. <xsl:value-of
				select="meta/year"/>. [<xsl:value-of select="$url"/>] </xsl:for-each>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Browse Template                                                        -->
	<!-- ====================================================================== -->

	<xsl:template match="crossQueryResult" mode="browse" exclude-result-prefixes="#all">

		<xsl:variable name="alphaList"
			select="'A B C D E F G H I J K L M N O P Q R S T U V W Y Z OTHER'"/>

		<html xml:lang="en" lang="en">
			<head>
				<title>XTF: Search Results</title>
				<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
				<xsl:copy-of select="$brand.links"/>
				<!-- AJAX support -->
				<script src="script/yui/yahoo-dom-event.js" type="text/javascript"/>
				<script src="script/yui/connection-min.js" type="text/javascript"/>
			</head>
			<body>
				<!-- header -->
				<xsl:copy-of select="$brand.header"/>

				<!-- result header -->
				<div class="resultsHeader">
					<table>
						<tr>
							<td colspan="2" class="right">
								<xsl:variable name="bag" select="session:getData('bag')"/>
								<a href="{$xtfURL}{$crossqueryPath}?smode=showBag">Bookbag</a>
									(<span id="bagCount">
									<xsl:value-of select="count($bag/bag/savedDoc)"/>
								</span>) </td>
						</tr>
						<tr>
							<td>
								<b>Browse by:&#160;</b>
								<xsl:choose>
									<xsl:when test="$browse-title">Title</xsl:when>
									<xsl:when test="$browse-creator">Author</xsl:when>
									<xsl:otherwise>All Items</xsl:otherwise>
								</xsl:choose>
							</td>
							<td class="right">
								<a href="{$xtfURL}{$crossqueryPath}">
									<xsl:text>New Search</xsl:text>
								</a>
								<xsl:if test="$smode = 'showBag'">
									<xsl:text>&#160;|&#160;</xsl:text>
									<a href="{session:getData('queryURL')}">
										<xsl:text>Return to Search Results</xsl:text>
									</a>
								</xsl:if>
							</td>
						</tr>
						<tr>
							<td>
								<b>Results:&#160;</b>
								<xsl:variable name="items" select="facet/group[docHit]/@totalDocs"/>
								<xsl:choose>
									<xsl:when test="$items &gt; 1">
										<xsl:value-of select="$items"/>
										<xsl:text> Items</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$items"/>
										<xsl:text> Item</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td class="right">
								<xsl:text>Browse by </xsl:text>
								<xsl:call-template name="browseLinks"/>
							</td>
						</tr>
						<tr>
							<td colspan="2" class="center">
								<xsl:call-template name="alphaList">
									<xsl:with-param name="alphaList" select="$alphaList"/>
								</xsl:call-template>
							</td>
						</tr>

					</table>
				</div>

				<!-- results -->
				<div class="results">
					<table>
						<tr>
							<td>
								<xsl:choose>
									<xsl:when test="$browse-title">
										<xsl:apply-templates
											select="facet[@field='browse-title']/group/docHit"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:apply-templates
											select="facet[@field='browse-creator']/group/docHit"/>
									</xsl:otherwise>
								</xsl:choose>
							</td>
						</tr>
					</table>
				</div>

				<!-- footer -->
				<xsl:copy-of select="$brand.footer"/>

			</body>
		</html>
	</xsl:template>

	<xsl:template name="browseLinks">
		<xsl:choose>
			<xsl:when test="$browse-all">
				<xsl:text>Facet | </xsl:text>
				<a href="{$xtfURL}{$crossqueryPath}?browse-title=first;sort=title">Title</a>
				<xsl:text> | </xsl:text>
				<a href="{$xtfURL}{$crossqueryPath}?browse-creator=first;sort=creator">Author</a>
			</xsl:when>
			<xsl:when test="$browse-title">
				<a href="{$xtfURL}{$crossqueryPath}?browse-all=yes">Facet</a>
				<xsl:text> | Title | </xsl:text>
				<a href="{$xtfURL}{$crossqueryPath}?browse-creator=first;sort=creator">Author</a>
			</xsl:when>
			<xsl:when test="$browse-creator">
				<a href="{$xtfURL}{$crossqueryPath}?browse-all=yes">Facet</a>
				<xsl:text> | </xsl:text>
				<a href="{$xtfURL}{$crossqueryPath}?browse-title=first;sort=title">Title</a>
				<xsl:text>  | Author</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<a href="{$xtfURL}{$crossqueryPath}?browse-all=yes">Facet</a>
				<xsl:text> | </xsl:text>
				<a href="{$xtfURL}{$crossqueryPath}?browse-title=first;sort=title">Title</a>
				<xsl:text> | </xsl:text>
				<a href="{$xtfURL}{$crossqueryPath}?browse-creator=first;sort=creator">Author</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Document Hit Template                                                  -->
	<!-- ====================================================================== -->

	<xsl:template match="docHit" exclude-result-prefixes="#all">

		<xsl:variable name="path" select="@path"/>

		<xsl:variable name="identifier" select="meta/identifier[1]"/>
		<xsl:variable name="quotedID" select="concat('&quot;', $identifier, '&quot;')"/>
		<xsl:variable name="indexId" select="replace($identifier, '.*/', '')"/>

		<!-- scrolling anchor -->
		<xsl:variable name="anchor">
			<xsl:choose>
				<xsl:when test="$sort = 'creator'">
					<xsl:value-of select="substring(string(meta/creator[1]), 1, 1)"/>
				</xsl:when>
				<xsl:when test="$sort = 'title'">
					<xsl:value-of select="substring(string(meta/title[1]), 1, 1)"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<div id="main_{@rank}" class="docHit">
			<dl class="result_list">

				<div>
					<dt>
						<xsl:if test="$sort = ''">
							<span style="float:left;">
								<b>
									<xsl:value-of select="@rank"/>
								</b>
							</span>
						</xsl:if>
						<xsl:if test="$sort = 'title'">
							<a name="{$anchor}"/>
						</xsl:if>
						<b>Title:</b>
					</dt>
					<dd>
						<a>
							<xsl:attribute name="href">
								<xsl:choose>
									<xsl:when test="matches(meta/display, 'dynaxml')">
										<xsl:call-template name="dynaxml.url">
											<xsl:with-param name="path" select="$path"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="rawDisplay.url">
											<xsl:with-param name="path" select="$path"/>
										</xsl:call-template>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<xsl:choose>
								<xsl:when test="meta/title">
									<xsl:apply-templates select="meta/title[1]"/>
								</xsl:when>
								<xsl:otherwise>none</xsl:otherwise>
							</xsl:choose>
						</a>
					</dd>
				</div>
				<div>
					<dt>
						<b>Repository:</b>
					</dt>
					<dd>
						<xsl:choose>
							<xsl:when test="meta/publisher">
								<xsl:apply-templates select="meta/publisher"/>
							</xsl:when>
							<xsl:otherwise>none</xsl:otherwise>
						</xsl:choose>
					</dd>
				</div>
				<!--<xsl:if test="not(meta/creator = 'unknown')">
					<div>
						<dt>
							<b>Author:</b>
						</dt>
						<dd>
							<xsl:choose>
								<xsl:when test="meta/creator">
									<xsl:apply-templates select="meta/creator"/>
								</xsl:when>
								<xsl:otherwise>none</xsl:otherwise>
							</xsl:choose>
						</dd>
					</div>
				</xsl:if>-->
				<div>
					<dt>
						<b>Published:</b>
					</dt>
					<dd>
						<xsl:choose>
							<xsl:when test="meta/year">
								<xsl:value-of select="replace(meta/year,'^.+ ','')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="meta/date"/>
							</xsl:otherwise>
						</xsl:choose>
					</dd>
				</div>
				<xsl:if test="meta/subject">
					<div>
						<dt>
							<b>Subjects:</b>
						</dt>
						<dd>
							<xsl:apply-templates select="meta/subject"/>
						</dd>
					</div>
				</xsl:if>
				<xsl:if test="snippet">
					<div>
						<dt><b>Matches:</b>
							<br/>
							<xsl:value-of select="@totalHits"/>
							<xsl:value-of select="if (@totalHits = 1) then ' hit' else ' hits'"
							/>&#160;&#160;&#160;&#160; </dt>
						<dd>
							<xsl:apply-templates select="snippet" mode="text"/>
						</dd>
					</div>
				</xsl:if>

				<!-- "more like this" -->
				<!-- commented out by Ethan for now.-->
				<!--<div>
					<dt>
						<b>Similar Items:</b>
					</dt>
					<dd>
						<script type="text/javascript"> getMoreLike_<xsl:value-of select="@rank"/> =
							function() { var span = YAHOO.util.Dom.get('moreLike_<xsl:value-of
								select="@rank"/>'); span.innerHTML = "Fetching...";
							YAHOO.util.Connect.asyncRequest('GET', '<xsl:value-of
								select="concat('search?smode=moreLike;docsPerPage=5;identifier=', $identifier)"
							/>', { success: function(o) { span.innerHTML = o.responseText; },
							failure: function(o) { span.innerHTML = "Failed!" } }, null); }; </script>
						<span id="moreLike_{@rank}">
							<a href="javascript:getMoreLike_{@rank}()">Find</a>
						</span>
					</dd>
				</div>-->
			</dl>
		</div>

	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Snippet Template (for snippets in the full text)                       -->
	<!-- ====================================================================== -->

	<xsl:template match="snippet" mode="text" exclude-result-prefixes="#all">
		<xsl:if test="position() &lt; 4">
			<xsl:text>...</xsl:text>
			<xsl:apply-templates mode="text"/>
			<xsl:text>...</xsl:text>
			<br/>
		</xsl:if>
	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Term Template (for snippets in the full text)                          -->
	<!-- ====================================================================== -->

	<xsl:template match="term" mode="text" exclude-result-prefixes="#all">
		<xsl:variable name="path" select="ancestor::docHit/@path"/>
		<xsl:variable name="display" select="ancestor::docHit/meta/display"/>
		<xsl:variable name="hit.rank">
			<xsl:value-of select="ancestor::snippet/@rank"/>
		</xsl:variable>
		<xsl:variable name="snippet.link">
			<xsl:call-template name="dynaxml.url">
				<xsl:with-param name="path" select="$path"/>
			</xsl:call-template>
			<xsl:value-of select="concat(';hit.rank=', $hit.rank, '#', $hit.rank )"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="ancestor::query"/>
			<xsl:when test="not(ancestor::snippet) or not(matches($display, 'dynaxml'))">
				<span class="hit">
					<xsl:apply-templates/>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<a href="{$snippet.link}" class="hit">
					<xsl:apply-templates/>
				</a>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!-- ====================================================================== -->
	<!-- Term Template (for snippets in meta-data fields)                       -->
	<!-- ====================================================================== -->

	<xsl:template match="term" exclude-result-prefixes="#all">
		<xsl:choose>
			<xsl:when test="ancestor::query"/>
			<xsl:otherwise>
				<span class="hit">
					<xsl:apply-templates/>
				</span>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!-- ====================================================================== -->
	<!-- More Like This Template                                                -->
	<!-- ====================================================================== -->

	<!-- results -->
	<xsl:template match="crossQueryResult" mode="moreLike" exclude-result-prefixes="#all">
		<xsl:choose>
			<xsl:when test="docHit">
				<div class="moreLike">
					<ol>
						<xsl:apply-templates select="docHit" mode="moreLike"/>
					</ol>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div class="moreLike">
					<b>No similar documents found.</b>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- docHit -->
	<xsl:template match="docHit" mode="moreLike" exclude-result-prefixes="#all">

		<xsl:variable name="path" select="@path"/>

		<li>
			<xsl:apply-templates select="meta/publisher"/>
			<xsl:text>. </xsl:text>
			<a>
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="matches(meta/display, 'dynaxml')">
							<xsl:call-template name="dynaxml.url">
								<xsl:with-param name="path" select="$path"/>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="rawDisplay.url">
								<xsl:with-param name="path" select="$path"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="meta/title[1]"/>
			</a>
			<xsl:text>. </xsl:text>
			<xsl:apply-templates select="meta/year[1]"/>
			<xsl:text>. </xsl:text>
		</li>

	</xsl:template>

	
	<!-- ====================================================================== -->
	<!-- Sort Options                                                           -->
	<!-- ====================================================================== -->
	<!-- This takes precedence over sort.options in common/resultFormatterCommon.xsl  -->
	
	<xsl:template name="sort.options">
		<select size="1" name="sort">
			<xsl:choose>
				<xsl:when test="$smode='showBag'">
					<xsl:choose>
						<xsl:when test="$sort = ''">
							<option value="title" selected="selected">title</option>
							<option value="creator">author</option>
							<option value="year">publication date</option>
							<option value="reverse-year">reverse date</option>
						</xsl:when>
						<xsl:when test="$sort = 'title'">
							<option value="title" selected="selected">title</option>
							<option value="creator">author</option>
							<option value="year">publication date</option>
							<option value="reverse-year">reverse date</option>
						</xsl:when>
						<xsl:when test="$sort = 'creator'">
							<option value="title">title</option>
							<option value="creator" selected="selected">author</option>
							<option value="year">publication date</option>
							<option value="reverse-year">reverse date</option>
						</xsl:when>
						<xsl:when test="$sort = 'year'">
							<option value="title">title</option>
							<option value="creator">author</option>
							<option value="year" selected="selected">publication date</option>
							<option value="reverse-year">reverse date</option>
						</xsl:when>
						<xsl:when test="$sort = 'reverse-year'">
							<option value="title">title</option>
							<option value="creator">author</option>
							<option value="year">publication date</option>
							<option value="reverse-year" selected="selected">reverse date</option>
						</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$sort = ''">
							<option value="" selected="selected">Relevance</option>
							<option value="totalHits">raw hit counts</option>
							<option value="score" >score</option>
							<option value="title">Title</option>
							<option value="identifier">Repository, id-number</option>
							<option value="collection-number">Repository, collection-number</option>
							<option value="year">Date, Ascending</option>
							<option value="reverse-year">Date, Descending</option>
						</xsl:when>
						
						<xsl:when test="$sort = 'totalHits'">
							<option value="" >Relevance</option>
							<option value="totalHits" selected="selected">raw hit counts</option>
							<option value="title">Title</option>
							<option value="identifier">Repository, id-number</option>
							<option value="collection-number">Repository, collection-number</option>
							<option value="year">Date, Ascending</option>
							<option value="reverse-year">Date, Descending</option>
						</xsl:when>
						
						<xsl:when test="$sort = 'title'">
							<option value="">Relevance</option>
							<option value="totalHits">raw hit counts</option>
							<option value="title" selected="selected">Title</option>
							<option value="collection-number">Repository, collection-number</option>
							<option value="identifier">Repository, id-number</option>
							<option value="year">Date, Ascending</option>
							<option value="reverse-year">Date, Descending</option>
						</xsl:when>
						<xsl:when test="$sort = 'identifier'">
							<option value="">Relevance</option>
							<option value="totalHits">raw hit counts</option>
							<option value="title">Title</option>
							<option value="identifier" selected="selected">Repository, id-number</option>
							<option value="collection-number">Repository, collection-number</option>
							<option value="year">Date, Ascending</option>
							<option value="reverse-year">Date, Descending</option>
						</xsl:when>
						<xsl:when test="$sort = 'collection-number'">
							<option value="">Relevance</option>
							<option value="totalHits">raw hit counts</option>
							<option value="title">Title</option>
							<option value="identifier" >Repository, id-number</option>
							<option value="collection-number" selected="selected">Repository, collection-number</option>
							<option value="year">Date, Ascending</option>
							<option value="reverse-year">Date, Descending</option>
						</xsl:when>
						<xsl:when test="$sort = 'year'">
							<option value="">Relevance</option>
							<option value="totalHits">raw hit counts</option>
							<option value="title">Title</option>
							<option value="identifier">Repository, id-number</option>
							<option value="collection-number">Repository, collection-number</option>
							<option value="year" selected="selected">Date, Ascending</option>
							<option value="reverse-year">Date, Descending</option>
						</xsl:when>
						<xsl:when test="$sort = 'reverse-year'">
							<option value="">Relevance</option>
							<option value="totalHits">raw hit counts</option>
							<option value="title">Title</option>
							<option value="identifier">Repository, id-number</option>
							<option value="collection-number">Repository, collection-number</option>
							<option value="year">Date, Ascending</option>
							<option value="reverse-year" selected="selected">Date, Descending</option>
						</xsl:when>
						<!-- 
						<xsl:when test="$sort = ''">
							<option value="" selected="selected">relevance</option>
							<option value="title">title</option>
							<option value="creator">author</option>
							<option value="year">publication date</option>
							<option value="reverse-year">reverse date</option>
						</xsl:when>
						<xsl:when test="$sort = 'title'">
							<option value="">relevance</option>
							<option value="title" selected="selected">title</option>
							<option value="creator">author</option>
							<option value="year">publication date</option>
							<option value="reverse-year">reverse date</option>
						</xsl:when>
						<xsl:when test="$sort = 'creator'">
							<option value="">relevance</option>
							<option value="title">title</option>
							<option value="creator" selected="selected">author</option>
							<option value="year">publication date</option>
							<option value="reverse-year">reverse date</option>
						</xsl:when>
						<xsl:when test="$sort = 'year'">
							<option value="">relevance</option>
							<option value="title">title</option>
							<option value="creator">author</option>
							<option value="year" selected="selected">publication date</option>
							<option value="reverse-year">reverse date</option>
						</xsl:when>
						<xsl:when test="$sort = 'reverse-year'">
							<option value="">relevance</option>
							<option value="title">title</option>
							<option value="creator">author</option>
							<option value="year">publication date</option>
							<option value="reverse-year" selected="selected">reverse date</option>
							</xsl:when> -->
						
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</select>
	</xsl:template>  
	
	

</xsl:stylesheet>
