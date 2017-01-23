<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">
  
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Mappings declared on ticket at https://gitlab.coko.foundation/wendell/XSweet/issues/16  -->
  
  <!-- A p matches *only* when it contains element(s) span[@style='font-size: 24']/b
       *and* it has no (non-ws) text nodes outside such element(s) -->
  <xsl:template match="p[exists(span[@style='font-size: 24']/b)]
    [empty(../text()[matches(.,'\S')] except span[@style='font-size: 24']/b/text())]">
    <h1>
      <xsl:for-each select="span/b">
        <xsl:apply-templates/>
      </xsl:for-each>
    </h1>
  </xsl:template>

  <!-- Similarly for p containing span[@style='font-size: 20']/b/i -->
  <xsl:template match="p[exists(span[@style='font-size: 20']/b/i)][empty(../text() except span[@style='font-size: 20']/b/i/text())]">
    <h2>
      <xsl:for-each select="span/b/i">
        <xsl:apply-templates/>
      </xsl:for-each>
    </h2>
  </xsl:template>
  
</xsl:stylesheet>