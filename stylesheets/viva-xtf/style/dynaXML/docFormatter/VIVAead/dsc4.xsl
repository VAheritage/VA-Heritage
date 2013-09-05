<!--Revision date 21 July 2004-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xtf="http://cdlib.org/xtf"
	xmlns="http://www.w3.org/1999/xhtml" version="1.0">
	<!-- This stylesheet formats the dsc portion of a finding aid.-->
	<!--It formats components that have 2 container elements of any type.-->
	<!--It assumes that c01 and optionally <c02> is a high-level description
      such as a series, subseries, subgroup or subcollection and does not have container
      elements associated with it. However, it does accommodate situations
      where there a <c01> that is a file is occasionally interspersed. However,
      if <c01> is always a file, use dsc10.xsl instead. -->
	<!--Column headings for containers are displayed when either the value or
      the type of a component's first container differs from that of
      the comparable container in the preceding component. -->
	<!-- The content of column headings are taken from the type
      attribute of the container elements.-->
	<!--The content of any and all container elements is always displayed.-->

	<!-- .................Section 1.................. -->

	<!--This section of the stylesheet formats dsc, its head, and
      any introductory paragraphs.-->

	<xsl:template match="archdesc/dsc">
		<xsl:apply-templates/>
	</xsl:template>

	<!--Formats dsc/head and makes it a link target.-->
	<xsl:template match="dsc/head">
		<h3>
			<a name="{xtf:make-id(.)}">
				<xsl:apply-templates/>
			</a>
		</h3>
	</xsl:template>

	<xsl:template match="dsc/p | dsc/note/p">
		<p style="margin-left:25pt">
			<xsl:apply-templates/>
		</p>
	</xsl:template>

	<!-- ...............Section 3.............................. -->
	<!--This section of the stylesheet creates an HTML table for each c01.
      It then recursively processes each child component of the
      c01 by calling a named template specific to that component level.
      The named templates are in section 4.-->

	<xsl:template match="c01">
		<xsl:choose>
			<xsl:when test="@level='item' or @level='file'">
				<div class="c01_item">
					<xsl:apply-templates select="did"/>
					<xsl:apply-templates
						select="head|bioghist|scopecontent|arrangement|accessrestrict|userestrict|prefercite|acqinfo|altformavail|accruals|appraisal|custodhist|processinfo|originalsloc|phystech|odd|note|physdesc"
						mode="did_level"/>
				</div>
				<xsl:if test="c02">
					<xsl:choose>
						<xsl:when test="not(descendant::*/did/container)">
							<ul class="no_con">
								<xsl:apply-templates select="c02"/>
							</ul>
						</xsl:when>
						<xsl:otherwise>
							<ul>
								<xsl:apply-templates select="c02"/>
							</ul>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>				
			</xsl:when>
			<xsl:otherwise>
				<div class="c01">
					<xsl:if test="@level='series'">
						<a>
							<xsl:attribute name="name">
								<xsl:text>series</xsl:text>
								<xsl:number from="dsc" count="c01 "/>
							</xsl:attribute>
						</a>
					</xsl:if>
					<xsl:apply-templates select="did"/>
					<xsl:apply-templates
						select="head|bioghist|scopecontent|arrangement|accessrestrict|userestrict|prefercite|acqinfo|altformavail|accruals|appraisal|custodhist|processinfo|originalsloc|phystech|odd|note|physdesc"
						mode="did_level"/>
					<xsl:if test="c02">
						<xsl:choose>
							<xsl:when test="not(descendant::*/did/container)">
								<ul class="no_con">
									<xsl:apply-templates select="c02"/>
								</ul>
							</xsl:when>
							<xsl:otherwise>
								<ul>
									<xsl:apply-templates select="c02"/>
								</ul>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="@level='series'">
						<div class="backtotop">
							<a href="#top" target="_self">Back to Top</a>
						</div>
					</xsl:if>
				</div>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<xsl:template match="c02 | c03 | c04 | c05 | c06 | c07 | c08">
		<li>
			<xsl:if test="parent::c01 and @level='subseries'">
				<a>
					<xsl:attribute name="name">
						<xsl:text>subseries</xsl:text>
						<xsl:value-of select="count(preceding::c02[@level='subseries'])+1"/>
					</xsl:attribute>
				</a>
			</xsl:if>
			<!--<div style="margin-left:40px;display:inline;">-->
			<xsl:apply-templates select="did"/>
			<xsl:apply-templates
				select="head|bioghist|scopecontent|arrangement|accessrestrict|userestrict|prefercite|acqinfo|altformavail|accruals|appraisal|custodhist|processinfo|originalsloc|phystech|odd|note|physdesc"
				mode="did_level"/>
			<xsl:if test="c03 | c04 | c05 | c06 | c07 | c08">
				<ul>
					<xsl:apply-templates select="c03 | c04 | c05 | c06 | c07 | c08"/>
				</ul>
			</xsl:if>
		</li>
		<!--</div>-->
	</xsl:template>

	<xsl:template match="did">
		<xsl:if test="not(parent::node()[@level='series'])">
			<xsl:for-each select="container">
				<xsl:apply-templates select=".">
					<xsl:with-param name="position" select="position()"/>
				</xsl:apply-templates>
			</xsl:for-each>
		</xsl:if>
		<xsl:apply-templates select="repository"/>
		<xsl:apply-templates select="unitid"/>
		<xsl:apply-templates select="head" mode="content"/>
		<xsl:apply-templates select="unittitle" mode="content"/>
		<xsl:if test="parent::node()/@level='series'">
			<xsl:apply-templates select="container"/>
		</xsl:if>
		<xsl:if test="physloc">
			<b>Physical Location: </b>
			<xsl:apply-templates select="physloc"/>
		</xsl:if>

		<xsl:apply-templates
			select="daogrp|langmaterial|note|origination|physdesc|unitdate|abstract|physdesc"
			mode="did_level"/>

		<xsl:if test="dao">
			<div class="ldd" name="{name()}">
				<b>Images: </b>
				<xsl:apply-templates select="descendant::dao"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="unittitle" mode="content">
		<div class="ut">
			<xsl:choose>
				<xsl:when test="parent::node()/parent::node()/@level = 'subseries'">
					<b>
						<xsl:if test="@label">
							<xsl:value-of select="@label"/>
							<xsl:text>: </xsl:text>
						</xsl:if>
						<xsl:apply-templates/>
					</b>
				</xsl:when>
				<xsl:when test="parent::did/parent::node()[@level = 'series']">
					<span class="c01_header">
						<xsl:if test="@label">
							<xsl:value-of select="@label"/>
							<xsl:text>: </xsl:text>
						</xsl:if>
						<xsl:apply-templates/>
					</span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="@label">
						<xsl:value-of select="@label"/>
						<xsl:text>: </xsl:text>
					</xsl:if>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<xsl:template match="head" mode="content">
		<xsl:choose>
			<xsl:when test="parent::did/parent::c01">
				<span class="c01_header">
					<xsl:value-of select="."/>
				</span>
			</xsl:when>
			<xsl:otherwise><xsl:value-of select="."/>: </xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<xsl:template
		match="head|bioghist|scopecontent|arrangement|accessrestrict|userestrict|prefercite|acqinfo|altformavail|accruals|appraisal|custodhist|processinfo|originalsloc|phystech|odd|note|physdesc"
		mode="did_level">
		<div class="ldd" name="{name()}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template name="container_labels">
		<xsl:variable name="current1">
			<xsl:if
				test="string(normalize-space(parent::node()/parent::node()/did/container[1]/@label))">
				<xsl:value-of select="@label"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="prev1">
			<xsl:value-of
				select="parent::node()/parent::node()/preceding-sibling::*/did/container[1]/@label"
			/>
		</xsl:variable>

		<xsl:variable name="current2">
			<xsl:if
				test="string(normalize-space(parent::node()/parent::node()/did/container[2]/@label))">
				<xsl:value-of select="parent::node()/parent::node()/did/container[2]/@label"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="prev2">
			<xsl:value-of
				select="parent::node()/parent::node()/preceding-sibling::*/did/container[2]/@label"
			/>
		</xsl:variable>

		<xsl:variable name="style">
			<xsl:choose>
				<xsl:when test="parent::node()/parent::c02">
					<xsl:text>margin-left:-200px;</xsl:text>
				</xsl:when>
				<xsl:when test="parent::node()/parent::c03">
					<xsl:text>margin-left:-250px;</xsl:text>
				</xsl:when>
				<xsl:when test="parent::node()/parent::c04">
					<xsl:text>margin-left:-300px;</xsl:text>
				</xsl:when>
				<xsl:when test="parent::node()/parent::c05">
					<xsl:text>margin-left:-350px;</xsl:text>
				</xsl:when>
				<xsl:when test="parent::node()/parent::c06">
					<xsl:text>margin-left:-400px;</xsl:text>
				</xsl:when>
				<xsl:when test="parent::node()/parent::c07">
					<xsl:text>margin-left:-450px;</xsl:text>
				</xsl:when>
				<xsl:when test="parent::node()/parent::c08">
					<xsl:text>margin-left:-500px;</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="not($current1 = $prev1) and not($current2 = $prev2)">
				<div style="display:table;color:#324395;">
					<div style="width:100px;float:left;{$style}">
						<xsl:value-of select="$current1"/>
					</div>
					<div style="width:100px;padding-left:100px;float:left;{$style}">
						<xsl:value-of select="$current2"/>
					</div>
				</div>
			</xsl:when>
			<xsl:when test="not($current1 = $prev1) and $current2 = $prev2">
				<div style="display:table;color:#324395;">
					<div style="{$style}">
						<xsl:value-of select="$current1"/>
					</div>
				</div>
			</xsl:when>
			<xsl:when test="$current1 = $prev1 and not($current2 = $prev2)">
				<div style="display:table;color:#324395;">
					<div style="padding-left:100px;{$style}">
						<xsl:value-of select="$current2"/>
					</div>
				</div>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="container">
		<xsl:param name="position"/>
		<xsl:choose>
			<xsl:when test="parent::node()/parent::node()[@level='series']">
				<div class="ldd">
					<xsl:if test="@label[.!='']">

						<xsl:value-of select="@label"/>
						<xsl:text>: </xsl:text>

					</xsl:if>
					<xsl:apply-templates/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="style">
					<xsl:choose>
						<xsl:when test="$position = '1'">
							<xsl:choose>
								<xsl:when test="parent::node()/parent::c02">
									<xsl:text>margin-left:-200px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c03">
									<xsl:text>margin-left:-250px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c04">
									<xsl:text>margin-left:-300px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c05">
									<xsl:text>margin-left:-350px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c06">
									<xsl:text>margin-left:-400px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c07">
									<xsl:text>margin-left:-450px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c08">
									<xsl:text>margin-left:-500px;</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="$position = '2'">
							<xsl:choose>
								<xsl:when test="parent::node()/parent::c02">
									<xsl:text>margin-left:-100px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c03">
									<xsl:text>margin-left:-150px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c04">
									<xsl:text>margin-left:-200px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c05">
									<xsl:text>margin-left:-250px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c06">
									<xsl:text>margin-left:-300px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c07">
									<xsl:text>margin-left:-350px;</xsl:text>
								</xsl:when>
								<xsl:when test="parent::node()/parent::c08">
									<xsl:text>margin-left:-400px;</xsl:text>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>

				<xsl:if test="$debug.labels">
					<xsl:if test="$position = '1'">
					<xsl:choose>
						<xsl:when test="not(ancestor::c01//container[2])">
							<xsl:variable name="current">
								<xsl:if
									test="string(normalize-space(parent::node()/parent::node()/did/container/@label))">
									<xsl:value-of select="@label"/>
								</xsl:if>
							</xsl:variable>
							<xsl:variable name="prev">
								<xsl:value-of
									select="parent::node()/parent::node()/preceding-sibling::*/did/container/@label"
								/>
							</xsl:variable>

							<xsl:if test="not($current = $prev)">
								<div style="display:table;color:#324395;{$style}">
									<xsl:value-of select="$current"/>
								</div>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="container_labels"/>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:if>
				</xsl:if>

				<div style="float:left;width:100px;{$style}">
					<xsl:if test="not($debug.labels)"><xsl:value-of select="@label"/></xsl:if><xsl:text> </xsl:text><xsl:value-of select="."/>
				</div>

			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="daogrp" mode="did_level">
		<div class="ldd" name="{name()}">
			<xsl:apply-templates select="daodesc"/>
			<b>Images: </b>
			<xsl:apply-templates select="daoloc"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
