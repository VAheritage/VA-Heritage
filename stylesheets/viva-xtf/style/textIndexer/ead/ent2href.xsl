<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="xs"
    version="2.0">
    

    <xsl:template match="@*|node()" priority="-10">
        <xsl:copy>
            <xsl:apply-templates  select="@*"/>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>
    

    <!-- unparsed-entities are not resolvable within a multi-stage XSLT pipeline.
        preFilter is the first stage, so we translate them here to hrefs while 
        we can still resolve the entities. 
     -->
    <xsl:template match="node()[@entityref and not (@href)]" mode="#all" > 
        <!--  for every element with an entityref but not href,
         add an href using the resolved value of the entity  -->        
        <xsl:copy>
            <xsl:attribute name="href"><xsl:value-of select="unparsed-entity-uri(@entityref)"/></xsl:attribute>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@entityref"  mode="#all" >
        <!--  null transform:  no output  -->
    </xsl:template>
    


    <xsl:template match="xi:include|include" mode="#all" priority="20000" >
        <xsl:apply-templates select="document(@href)"  mode="#current" />    
    </xsl:template>
    

</xsl:stylesheet>