<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsw="http://coko.foundation/xsweet"
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
  
  
<!-- This stylesheet repairs endnotes and their references:
     discarding unreferenced endnotes and re-ordering notes by order of first reference. -->
  
  <xsl:key name="endnote-by-id" match="p[@class='docx-endnote']" use="@id"/>
  
  <!--<a class="endnoteReference" href="#en{@w:id}">-->
  
  <!-- Retrieveing endnotes, keep only those that are referenced, in their order of reference. -->
  <xsl:template match="div[@class='docx-endnotes']">
    <xsl:variable name="notes" select="div[@class='docx-endnote']"/>
    <xsl:for-each select="../div[@class='docx-body']//a[@class='endnoteReference'][xsw:is-first-enref(.)]">
      <xsl:variable name="href" select="@href"/>
      <xsl:apply-templates select="$notes[concat('#',@id)=$href]"/>
    </xsl:for-each>
  </xsl:template>
  
  <!-- Expand placeholders for links with generated numbers if they have no values yet. -->
  <xsl:template match="a[@class='endnoteReference'][not(normalize-space(.))]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="." mode="get-number"/>
    </xsl:copy>
  </xsl:template>
  
  <!--<span class="EndnoteReference"/> inside end note text also needs expansion. -->
  <xsl:template match="span[@class='EndnoteReference'][not(normalize-space(.))]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="get-number"
        select="key('endnoteRef-by-href',concat('#',ancestor::div[@class='docx-endnote']/@id))[1]"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Since notes need to be counted, only first references to notes can
       be counted, and the order of notes depends on the order of (first)
       references to them, so that's the set of elements we need for counting. -->
  
  <xsl:key name="endnoteRef-by-href" match="a[@class='endnoteReference']"  use="@href"/>
  
  <xsl:function name="xsw:is-first-enref" as="xs:boolean">
    <xsl:param name="enref" as="element(a)"/>
    <!-- Boolean returns true() iff this is the first endnoteRef with its @id (and hence target). -->
    <xsl:sequence select="($enref/@class='endnoteReference') and ($enref is key('endnoteRef-by-href',$enref/@href,root($enref))[1])"/>
  </xsl:function>
  
  <xsl:template match="a[@class='endnoteReference']" mode="get-number">
    <xsl:for-each select="key('endnoteRef-by-href',@href)[1]">
      <xsl:number level="any" count="a[@class='endnoteReference'][xsw:is-first-enref(.)]"/>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>