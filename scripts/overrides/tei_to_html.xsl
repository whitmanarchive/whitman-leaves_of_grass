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


  <!-- add editorial policy statement to metadata -->
  <xsl:variable name="top_metadata">
    <ul>
      <li><strong>Source: </strong> 
        <em><xsl:apply-templates select="//sourceDesc//monogr//title"/></em><xsl:text> (</xsl:text><xsl:apply-templates select="//sourceDesc//monogr//pubPlace"/><xsl:if test="//sourceDesc//monogr//publisher">: <xsl:apply-templates select="//sourceDesc//monogr//publisher"/></xsl:if>, <xsl:apply-templates select="//sourceDesc//monogr//date"/><xsl:text>)</xsl:text>. <span class="copy_info"><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/repository"/><xsl:if test="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno"><xsl:text>, </xsl:text><xsl:value-of select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msIdentifier/idno"/></xsl:if><xsl:text>. </xsl:text></span><span><xsl:apply-templates select="//encodingDesc"/></span> For a description of the editorial rationale behind our treatment of editions of <em>Leaves of Grass</em>, see our <a href="../about/editorial-policies">statement of editorial policy</a>.
      </li>
              
      <xsl:if test="TEI/teiHeader//notesStmt/note[@type='editorial']">
        <li xmlns="http://www.w3.org/1999/xhtml">
          <strong>Editorial note(s): </strong> <xsl:apply-templates select="TEI/teiHeader//notesStmt/note[@type='editorial']"/></li>
      </xsl:if>

    </ul>
  </xsl:variable>


  <!-- add line group numbers -->
  <xsl:template match="l">
    <span>
      <xsl:attribute name="class">
        <xsl:call-template name="add_attributes"/>
      </xsl:attribute>
      <xsl:if test="@spanTo">
        <xsl:attribute name="data-spanto">
          <xsl:value-of select="./@spanTo"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@xml:id">
        <xsl:attribute name="data-xmlid">
          <xsl:value-of select="./@xml:id"/>
        </xsl:attribute>
      </xsl:if>
      <!-- display number if present -->
      <xsl:choose>
        <xsl:when test="ancestor::lg[@type='linegroup'] and not(preceding-sibling::l) and parent::lg/attribute::n">
          <sup class="tei_linegroup_number">
          <xsl:value-of select="parent::lg/attribute::n" />
          </sup>
          <xsl:apply-templates />
        </xsl:when>
        <!-- otherwise if no number -->
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </span>
  </xsl:template>
  
  <xsl:template match="pb">
    <!-- grab the figure id from @facs after tokenizing, and if there is a .jpg, chop it off
          note: I previously also looked at xml:id for figure ID, but that's 
          incorrect -->
    
    <xsl:variable name="pb_xmlid">
      <xsl:value-of select="@xml:id"/>
    </xsl:variable>
    <xsl:variable name="pb_n">
      <xsl:value-of select="@n"/>
    </xsl:variable>
    
    <xsl:for-each select="tokenize(@facs, ' ')">
      <xsl:variable name="figure_id">
        <xsl:variable name="figure_id_full">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="ends-with($figure_id_full, '.jpg') or ends-with($figure_id_full, '.jpeg')">
            <xsl:value-of select="substring-before($figure_id_full, '.jp')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$figure_id_full"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <span class="hr">&#160;
        <!-- if pb/@xml:id begins with "leaf" add language that looks like leaf 1 recto, leaf 1 verso, leaf 2 recto, etc -->
        <!-- changing rule to check format of xml:id - it does not work across the board. may need to generalize more  -->
        <xsl:if test="starts-with($pb_xmlid,'leaf') and string-length($pb_xmlid) &gt;= 8 and $pb_n != ''">
          <xsl:variable name="id" select="$pb_xmlid"/>
          <xsl:variable name="page"><xsl:value-of select="xs:decimal(substring(substring-after($pb_xmlid,'leaf'),1,3))"/></xsl:variable>
          <xsl:variable name="last_character" select="substring($pb_xmlid,8,8)"/>
          <xsl:variable name="rectoverso">
            <xsl:choose>
              <xsl:when test="$last_character = 'r'">recto</xsl:when>
              <xsl:when test="$last_character = 'v'">verso</xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:text>[ begin page </xsl:text>
          <xsl:value-of select="$pb_n"/>
          <xsl:text> ]</xsl:text>
        </xsl:if>
      </span>
      <xsl:if test="$figure_id != ''">
        <span>
          <xsl:attribute name="class">
            <xsl:text>pageimage</xsl:text>
          </xsl:attribute>
          <a>
            <!-- add id to links -->
            <xsl:attribute name="id">
              <xsl:value-of select="$pb_xmlid"/>
            </xsl:attribute>
            <!-- /add id to links -->
            <xsl:attribute name="href">
              <xsl:call-template name="url_builder">
                <xsl:with-param name="figure_id_local" select="$figure_id"/>
                <xsl:with-param name="image_size_local" select="$image_large"/>
                <xsl:with-param name="iiif_path_local" select="$collection"/>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="rel">
              <xsl:text>prettyPhoto[pp_gal]</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
              <xsl:text>&lt;a href=&#34;</xsl:text>
              <xsl:call-template name="url_builder_escaped">
                <xsl:with-param name="figure_id_local" select="$figure_id"/>
                <xsl:with-param name="image_size_local" select="$image_large"/>
                <xsl:with-param name="iiif_path_local" select="$collection"/>
              </xsl:call-template>
              <xsl:text>" target="_blank" &gt;open image in new window&lt;/a&gt;</xsl:text>
            </xsl:attribute>
            
            <img>
              <xsl:attribute name="src">
                <xsl:call-template name="url_builder">
                  <xsl:with-param name="figure_id_local" select="$figure_id"/>
                  <xsl:with-param name="image_size_local" select="$image_thumb"/>
                  <xsl:with-param name="iiif_path_local" select="$collection"/>
                </xsl:call-template>
              </xsl:attribute>
              <xsl:attribute name="class">
                <xsl:text>display&#160;</xsl:text>
              </xsl:attribute>
            </img>
          </a>
        </span>
        <span class="page_image_description"><xsl:value-of select="."/></span>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
