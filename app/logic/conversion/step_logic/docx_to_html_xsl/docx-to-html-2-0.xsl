<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
    xmlns:mo="http://schemas.microsoft.com/office/mac/office/2008/main"
    xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
    xmlns:mv="urn:schemas-microsoft-com:mac:vml" xmlns:o="urn:schemas-microsoft-com:office:office"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:rel="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
    xmlns:v="urn:schemas-microsoft-com:vml"
    xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    xmlns:w10="urn:schemas-microsoft-com:office:word"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
    xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"
    xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
    xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
    xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
    xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
    xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dcmitype="http://purl.org/dc/dcmitype/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.0">
    <xsl:output method="xhtml"/>

    <!-- Vanilla stylesheet from which to build up for docx - > html conversions -->
    <!-- The trigger/input document is immaterial, since the only file that is acted upon is the one 
        defined by the variables below -->

    <!-- This stylesheet assumes that the Word document is in the same directory as the XSLT -->
    <xsl:param name="name-of-docx-file-to-convert" as="xs:string" select="'test.docx'"/>

    <xsl:variable name="static-base-uri" select="static-base-uri()"/>
    <xsl:variable name="source-uri"
        select="resolve-uri($name-of-docx-file-to-convert, $static-base-uri)"/>
    <xsl:variable name="source-jar-uri" select="concat('zip:', $source-uri, '!/')"/>
    <xsl:variable name="source-root-rels" select="doc(concat($source-jar-uri, '_rels/.rels'))"/>
    <xsl:variable name="source-word-rels"
        select="doc(concat($source-jar-uri, 'word/_rels/document.xml.rels'))"/>
    <xsl:variable name="source-docs"
        select="
            (for $i in $source-root-rels//@Target[matches(., '\.xml$')]
            return
                doc(concat($source-jar-uri, $i)),
            for $j in $source-word-rels//@Target[matches(., '\.xml$')]
            return
                doc(concat($source-jar-uri, 'word/', $j)))"/>
    <xsl:template match="/">
        <html>
            <head>
                <title>
                    <xsl:value-of select="$source-docs/cp:coreProperties/dc:title"/>
                </title>
            </head>
            <xsl:apply-templates select="$source-docs/w:document" mode="word-to-html"/>
        </html>
    </xsl:template>
    <xsl:template match="node()" mode="word-to-html">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="w:body" mode="word-to-html">
        <body>
            <xsl:apply-templates mode="word-to-html"/>
        </body>
    </xsl:template>
    <xsl:template match="w:p" mode="word-to-html">
        <div>
            <xsl:apply-templates mode="word-to-html"/>
        </div>
    </xsl:template>
    <xsl:template match="w:r[w:rPr/w:i]" mode="word-to-html">
        <i>
            <xsl:apply-templates mode="word-to-html"/>
        </i>
    </xsl:template>
    <xsl:template match="w:t" mode="word-to-html">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>
