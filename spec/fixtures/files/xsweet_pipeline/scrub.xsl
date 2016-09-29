<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">
  
  <!-- Indent should really be no, but for testing. -->
  <xsl:output method="xml" indent="no" omit-xml-declaration="yes"/>
  
  <!-- Copy everything by default. -->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Strip these, retaining their contents. -->
  <xsl:template match="position | iCs | lang | vertAlign | noProof">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Remove any 'p' element that has nothing but whitespace. -->
  <xsl:template match="p[not(matches(.,'\S'))]"/>

  <!-- Inline elements that are truly empty can be stripped. -->
  <xsl:template match="p//*[empty(*) and not(string(.))]">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Except these guys of course ... -->
  <xsl:template priority="5" match="img | br | hr">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Otherwise @style is rewritten to normalize its CSS. -->
  
  <xsl:template match="@style">
    <!-- Acquire properties by breaking at ';\s*' (semi-colon) and keeping only those that match
         a regex (requiring a colon followed by non-ws). -->
    <xsl:variable name="properties" select="tokenize(.,';\s*')[matches(.,':\s*\S')]"/>
    <!-- Doesn't handle just any CSS; assumes single space after ':' is normal. -->
    <!-- Grouping by value serves to remove duplicates. -->
    <xsl:attribute name="style">
      <xsl:for-each-group select="$properties" group-by=".">
        <!-- And also permits us to sort them. -->
        <xsl:sort select="."/>
        <xsl:if test="not(position() eq 1)">; </xsl:if>
        <xsl:value-of select="."/>
      </xsl:for-each-group>
    </xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>