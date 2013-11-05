<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xtf="http://cdlib.org/xtf"
    xmlns="urn:isbn:1-931666-22-9"
    exclude-result-prefixes="ead"
    version="1.0">
    

    <xsl:output method="xml" version="1.0" omit-xml-declaration="no" indent="yes"
        encoding="UTF-8"/>
    
    <!-- Path to schema -->
    
    <xsl:param name="schemaPath">
        <xsl:text>http://text.lib.virginia.edu/dtd/eadVIVA/</xsl:text>
    </xsl:param>

    <xsl:variable name="rng-model">
        <xsl:text>href=</xsl:text>
        <xsl:value-of select="concat( '&quot;', $schemaPath, 'ead-ext.rng&quot;' )" />
        <xsl:text>
		type="application/xml" 
		schematypens="http://relaxng.org/ns/structure/1.0" 
		title="extended EAD relaxng schema" </xsl:text>
    </xsl:variable>

    <xsl:variable name="sponsor">
        <xsl:value-of select='(/ead:ead/ead:frontmatter/ead:titlepage/ead:list[@type="deflist"]/ead:defitem[contains(label,"Funding")]/item)|(/ead:ead/ead:eadheader/ead:filedesc/ead:publicationstmt/ead:p[@id="sponsor"])'/>
    </xsl:variable>
    

    <!-- don't copy old stylesheet! VIVA/VHP: sdm7g -->
    <xsl:template match="processing-instruction('xml-stylesheet')" /> 
    
    <xsl:template match="node()|@*"> <!-- ident -->
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>


    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
				<xsl:value-of select="$rng-model"/>
			</xsl:processing-instruction>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="*|comment()"/>
    </xsl:template>


    <xsl:template match="ead:userestrict/ead:head[normalize-space(text())='Publication Rights']">
        <head>Use Restrictions</head>
    </xsl:template>

    <xsl:template match="ead:userestrict/ead:p[contains(.,'EDIT ME!') or contains(.,'There are no restrictions.')]">
        <p>See the 
            <extref xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="http://search.lib.virginia.edu/terms.html">
            University of Virginia Library’s use policy.</extref></p>
    </xsl:template>


    <xsl:template match="ead:accessrestrict/ead:p[contains(.,'EDIT ME!')]">
        <p>There are no restrictions.</p>
    </xsl:template>

    <xsl:template match="ead:accessrestrict/ead:head" >
        <head>Access Restrictions</head>
    </xsl:template>

    <xsl:template match="ead:prefercite/ead:p[contains(.,'EDIT ME!')]">
        <xsl:variable name="title" select="/ead:ead/ead:eadheader/ead:filedesc/ead:titlestmt/ead:titleproper/text()" />
        <xsl:variable name="cite">
            <xsl:choose>
                <xsl:when test="contains($title, 'A Guide to the ')">
                    <xsl:value-of select="substring-after( string($title), 'A Guide to the ')"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="string($title)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="accession" 
            select="/ead:ead/ead:eadheader/ead:filedesc/ead:titlestmt/ead:subtitle[@id='sort']/ead:num[@type='collectionnumber']" />
        <p>
            <xsl:value-of select="$cite"/>
            <xsl:if test="$accession">
                <xsl:text>, Accession </xsl:text>
                <xsl:value-of select="$accession"/>
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text> </xsl:text>
           <xsl:value-of select="/ead:ead/ead:frontmatter/ead:titlepage/ead:publisher"/>
        </p>
    </xsl:template>


<!--    <xsl:template match="ead:publicationstmt/ead:p[@id='usestatement']" >
        
    </xsl:template>-->


    <xsl:template match="/ead:ead/ead:eadheader/ead:filedesc/ead:publicationstmt/ead:address">
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude"  href="http://ead.lib.virginia.edu/vivaead/add_con/uva-sc_address.xi.xml" />
    </xsl:template>
    

    <xsl:template match="/ead:ead/ead:frontmatter/ead:titlepage/ead:list[@type='simple'][contains(ead:head,'Contact Information')][preceding-sibling::ead:publisher]" >
        <xi:include xmlns:xi="http://www.w3.org/2001/XInclude"  href="http://ead.lib.virginia.edu/vivaead/add_con/uva-sc_contact.xi.xml" />        
    </xsl:template>


    <xsl:template match="/ead:ead/ead:eadheader/ead:filedesc/ead:titlestmt">
        <xsl:copy>
            <xsl:apply-templates select="@*|*" />
            <xsl:if test="not(ead:sponsor) and $sponsor and ( string-length($sponsor) != 0 )" >
                <xsl:element name="sponsor">
                    <xsl:value-of select="$sponsor"/>		
                </xsl:element>
            </xsl:if>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>