<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:whitman="http://www.whitmanarchive.org/namespace"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0"
  exclude-result-prefixes="xsl tei xs whitman">
  
  <!-- ==================================================================== -->
  <!--                             IMPORTS                                  -->
  <!-- ==================================================================== -->
  
  <xsl:import href="../.xslt-datura/tei_to_html/tei_to_html.xsl"/>
  <xsl:import href="../../../whitman-scripts/scripts/archive-wide/overrides.xsl"/>

  <!-- To override, copy this file into your collection's script directory
    and change the above paths to:
    "../../.xslt-datura/tei_to_html/lib/formatting.xsl"
 -->
  
  <!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
  <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="no"/>



<xsl:variable name="top_metadata">
    <ul>
      <li><strong>Source: </strong> 

     
<em><xsl:apply-templates select="//sourceDesc//monogr//title"/></em><xsl:text> (</xsl:text><xsl:apply-templates select="//sourceDesc//monogr//pubPlace"/><xsl:if test="//sourceDesc//monogr//publisher">: <xsl:apply-templates select="//sourceDesc//monogr//publisher"/></xsl:if>, <xsl:apply-templates select="//sourceDesc//monogr//date"/><xsl:text>)</xsl:text>. <span class="copy_info"><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository"/><xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno"><xsl:text>, </xsl:text><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno"/></xsl:if><xsl:text>. </xsl:text></span><span><xsl:apply-templates select="//encodingDesc"/></span> For a description of the editorial rationale behind our treatment of editions of <em>Leaves of Grass</em>, see our <a href="../about/editorial-policies">statement of editorial policy</a>.</li>
              
              <xsl:if test="TEI/teiHeader//notesStmt/note[@type='editorial']"><li xmlns="http://www.w3.org/1999/xhtml"><strong>Editorial note(s): </strong> <xsl:apply-templates select="TEI/teiHeader//notesStmt/note[@type='editorial']"/></li>
              </xsl:if>



    </ul>
  </xsl:variable>




 
</xsl:stylesheet>
