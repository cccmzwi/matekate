<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" indent="no" encoding="UTF-8"/>

    <xsl:template match="/">
	<xsl:text>lat&#x9;lon&#x9;title&#x9;description&#x9;icon&#x9;iconSize&#x9;iconOffset&#xD;</xsl:text>
	<xsl:apply-templates/> 
    </xsl:template>

    <xsl:template match="node">

	<xsl:value-of select="@lat"/>
	<xsl:text>&#x9;</xsl:text>
	<xsl:value-of select="@lon"/>
	<xsl:text>&#x9;</xsl:text>

	<xsl:variable name="Name">
	    <xsl:for-each select="tag">
		<xsl:if test ="@k = 'name'">
		    <xsl:value-of select="@v"/>
		</xsl:if>
	    </xsl:for-each>
	</xsl:variable>
	<xsl:if test ="$Name = ''">
	    <xsl:text>(Name unbekannt)</xsl:text>
	</xsl:if>
	<xsl:if test ="$Name != ''">
	    <xsl:value-of select="$Name"/>
	</xsl:if>

	<xsl:text>&#x9;</xsl:text>

	<xsl:for-each select="tag">
	    <xsl:if test ="@k = 'addr:street'">
		<xsl:value-of select="@v"/>
	    </xsl:if>
	</xsl:for-each>

	<xsl:for-each select="tag">
	    <xsl:if test ="@k = 'addr:housenumber'">
		<xsl:text> </xsl:text><xsl:value-of select="@v"/>
	    </xsl:if>
	</xsl:for-each>

	<!--
	<xsl:text>&lt;/br&gt;id: </xsl:text><xsl:value-of select="@id"/>
	<xsl:text>&lt;/br&gt;Finder: </xsl:text><xsl:value-of select="@user"/>
	<xsl:text>&lt;/br&gt;Zeit: </xsl:text><xsl:value-of select="@timestamp"/>
	-->
	<xsl:text>&lt;/br&gt; &lt;/br&gt;Zum Schliessen das Symbol nochmal anklicken</xsl:text>
	<xsl:text>&#x9;http://www.cccmz.de/wp-content/uploads/2009/03/mate_icon_24.png&#x9;24,24&#x9;-12,-12&#xD;</xsl:text>
    </xsl:template>

    <xsl:template match="way">
	<!--koennen, nein, muessen wir ignorieren-->
    </xsl:template>

</xsl:stylesheet> 
