<?xml version="1.0" encoding="UTF-8"?>
<!--
	tmarc.xsl
	Stylesheet to extract Marc 21 fields from Indexdata’s streamlined
	turbomarc XML format to an internal metadat model for pazpar2.

	Mostly based on Indexdata’s original tmarc.xsl from
	http://git.indexdata.com/?p=pazpar2.git;a=blob_plain;f=etc/tmarc.xsl;hb=HEAD

	In parts modified, extended, streamlined by
	Sven-S. Porst, SUB Göttingen <porst@sub.uni-goettingen.de>

	This version can be found in the repository at github:
	https://github.com/ssp/pazpar2-etc/
-->
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:pz="http://www.indexdata.com/pazpar2/1.0"
  xmlns:tmarc="http://www.indexdata.com/turbomarc" version="1.0">

  <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8"/>

  <xsl:param name="medium"/>

  <xsl:template name="record-hook"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tmarc:collection">
    <collection>
      <xsl:apply-templates/>
    </collection>
  </xsl:template>

  <xsl:template match="tmarc:r">
    <xsl:variable name="title_medium" select="tmarc:d245/tmarc:sh"/>

    <!-- Assemble the parent’s title from 773 $a and $t. -->
    <xsl:variable name="parent-title">
      <xsl:value-of select="tmarc:d773/tmarc:sa"/>
      <xsl:if test="tmarc:d773/tmarc:sa and tmarc:d773/tmarc:st">
        <xsl:text>: </xsl:text>
	  </xsl:if>
      <xsl:value-of select="tmarc:d773/tmarc:st"/>
    </xsl:variable>

    <xsl:variable name="fulltext_a" select="tmarc:d900/tmarc:sa"/>
    <xsl:variable name="fulltext_b" select="tmarc:d900/tmarc:sb"/>

    <xsl:variable name="typeofrec" select="substring(tmarc:l, 7, 1)"/>
    <xsl:variable name="typeofvm" select="substring(tmarc:c008, 34, 1)"/>
    <xsl:variable name="biblevel" select="substring(tmarc:l, 8, 1)"/>
    <xsl:variable name="multipart" select="substring(tmarc:l, 20, 1)"/>

    <xsl:variable name="form1" select="substring(tmarc:c008, 24, 1)"/>
    <xsl:variable name="form2" select="substring(tmarc:c008, 30, 1)"/>
    <xsl:variable name="language" select="substring(tmarc:c008, 36, 3)"/>
    <xsl:variable name="oclca" select="substring(tmarc:c007, 1, 1)"/>
    <xsl:variable name="oclcb" select="substring(tmarc:c007, 2, 1)"/>
    <xsl:variable name="oclcd" select="substring(tmarc:c007, 4, 1)"/>
    <xsl:variable name="oclce" select="substring(tmarc:c007, 5, 1)"/>
    <xsl:variable name="typeofserial" select="substring(tmarc:c008, 22, 1)"/>



    <xsl:variable name="electronic">
      <xsl:choose>
        <xsl:when test="$form1='s' or $form1='q' or $form1='o' or $form2='s' or $form2='q' or $form2='o'">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="vmedium">
      <xsl:choose>
        <xsl:when test="string-length($medium)"><xsl:value-of select="$medium"/></xsl:when>
        <xsl:when test="$oclca='h' or $form1='a' or $form1='b' or $form1='c'">microform</xsl:when>
        <xsl:when test="$multipart='a'">multivolume</xsl:when>
        <xsl:when test="$typeofrec='j' or $typeofrec='i'">
          <xsl:text>recording</xsl:text>
          <xsl:choose>
            <xsl:when test="$oclcb='d' and $oclcd='f'">-cd</xsl:when>
            <xsl:when test="$oclcb='s'">-cassette</xsl:when>
            <xsl:when test="$oclcb='d' and $oclcd='a' or $oclcd='b' or $oclcd='c' or $oclcd='d' or $oclcd='e'">-vinyl</xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$typeofrec='g'">
          <xsl:choose>
            <xsl:when test="$typeofvm='m' or $typeofvm='v'">
              <xsl:text>video</xsl:text>
              <xsl:choose>
                <xsl:when test="$oclca='v' and $oclcb='d' and $oclce='v'">-dvd</xsl:when>
                <xsl:when test="$oclca='v' and $oclcb='d' and $oclce='s'">-blu-ray</xsl:when>
                <xsl:when test="$oclca='v' and $oclcb='f' and $oclce='b'">-vhs</xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>audio-visual</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$typeofrec='a' and $biblevel='s'">
          <xsl:choose>
            <xsl:when test="$typeofserial='n'">newspaper</xsl:when>
            <xsl:otherwise>journal</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$typeofrec='e' or $typeofrec='f'">map</xsl:when>
        <xsl:when test="$typeofrec='c' or $typeofrec='d'">music-score</xsl:when>
        <xsl:when test="$typeofrec='t'">manuscript</xsl:when>
        <xsl:when test="string-length($parent-title) &gt; 0">article</xsl:when>
        <xsl:when test="($typeofrec='a' or $typeofrec='t') and ($biblevel='m' or $biblevel='a')">book</xsl:when>
        <xsl:when test="($typeofrec='a' or $typeofrec='i') and ($typeofserial='d' or $typeofserial='w')">web</xsl:when>
        <xsl:when test="$typeofrec='a' and $biblevel='b'">article</xsl:when>
        <xsl:when test="$typeofrec='m'">electronic</xsl:when>
        <xsl:when test="$typeofrec='o'">multiple</xsl:when>
        <xsl:when test="$title_medium">
          <xsl:value-of select="translate($title_medium, ' []/:', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>other</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="has_fulltext">
      <xsl:choose>
        <xsl:when test="tmarc:d856/tmarc:sq">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:when test="tmarc:d856/tmarc:si='TEXT*'">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>no</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="oclc_number">
      <xsl:choose>
        <xsl:when test='contains(tmarc:c001,"ocn") or
                        contains(tmarc:c001,"ocm") or
                        contains(tmarc:c001,"OCoLC")'>
          <xsl:value-of select="tmarc:c001"/>
        </xsl:when>
        <xsl:when test='contains(tmarc:d035/tmarc:sa,"ocn") or
                        contains(tmarc:d035/tmarc:sa,"ocm") or
                        contains(tmarc:d035/tmarc:sa,"OCoLC")'>
          <xsl:value-of select="tmarc:d035/tmarc:sa"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="date_008">
      <xsl:choose>
        <xsl:when test="contains('cestpudikmr', substring(tmarc:c008, 7, 1))">
          <xsl:value-of select="substring(tmarc:c008, 8, 4)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="date_end_008">
      <xsl:choose>
        <xsl:when test="contains('dikmr', substring(tmarc:c008, 7, 1))">
          <xsl:value-of select="substring(tmarc:c008, 12, 4)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <pz:record>
      <!-- extract language information from: 008[35-37] ($language variable) and 041 $a fields -->
      <xsl:if test="$language!='und' and
                    $language!='zxx' and
                    $language!='   ' and
                    $language!='mul' and
                    $language!='|||'">
        <pz:metadata type="language">
          <xsl:value-of select="$language"/>
        </pz:metadata>
      </xsl:if>
      <xsl:for-each select="tmarc:d041">
        <!-- $a main, $b summary, $d audio, $e libretto, $f toc, $g additions, $j subtitles -->
        <xsl:for-each select="tmarc:sa | tmarc:sb | tmarc:sd | tmarc:se | tmarc:sf | tmarc:sg | tmarc:sj">
          <xsl:if test=". != $language and not(../@i2 = '7' and not(../tmarc:s2))">
            <!-- only add language codes which do not duplicate the one in c008 and, if non-standard, which contain information about their type -->
            <pz:metadata type="language">
              <!-- for non-standard language codes transport their type in the language-code-scheme attribute -->
              <xsl:if test="../@i2 = '7' and ../tmarc:s2">
                <xsl:attribute name="language-code-scheme">
                  <xsl:value-of select="../tmarc:s2"/>
                </xsl:attribute>
              </xsl:if>
          	  <xsl:value-of select="."/>
            </pz:metadata>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:c001">
        <pz:metadata type="id">
          <xsl:value-of select="."/>
        </pz:metadata>
      </xsl:for-each>

      <xsl:if test="string-length($oclc_number) &gt; 0">
        <pz:metadata type="oclc-number">
          <xsl:value-of select="$oclc_number"/>
        </pz:metadata>
      </xsl:if>

      <xsl:for-each select="tmarc:d010">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="lccn">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d020">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="isbn">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d022">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="issn">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d024">
        <xsl:if test="(tmarc:sa) and (tmarc:s2='doi')">
          <pz:metadata type="doi">
            <xsl:value-of select="tmarc:sa"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d027">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="tech-rep-nr">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d035">
        <pz:metadata type="system-control-nr">
          <xsl:choose>
            <xsl:when test="tmarc:sa">
              <xsl:value-of select="tmarc:sa"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tmarc:sb"/>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:for-each>

      <!-- DDC -->
      <xsl:for-each select="tmarc:d082">
        <pz:metadata type="classification-ddc">
          <xsl:value-of select="tmarc:sa"/>
        </pz:metadata>
      </xsl:for-each>

      <!-- Marc 084 contains generic classification numbers with the
           classification name in $2. Turn these into metadata fields with
           name classification-XXX where XXX is the content of $2.
           Create a new pazpar2 metadata field for each $a subfield.
      -->
      <xsl:for-each select="tmarc:d084">
        <xsl:variable name="classification-name">
          <xsl:value-of select="tmarc:s2"/>
        </xsl:variable>
        <xsl:for-each select="tmarc:sa">
          <pz:metadata>
            <xsl:attribute name="type">
              <xsl:text>classification</xsl:text>
              <xsl:if test="$classification-name">
                <xsl:text>-</xsl:text>
                <xsl:value-of select="translate($classification-name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
              </xsl:if>
            </xsl:attribute>
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>


      <xsl:for-each select="tmarc:d100 | tmarc:d700[tmarc:s4='aut']">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="author">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="author-title">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sd">
          <pz:metadata type="author-date">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d700">
        <xsl:if test="not(tmarc:sa = ../tmarc:d100/tmarc:sa) and not(tmarc:s4='aut')">
          <pz:metadata type="other-person">
            <xsl:value-of select="tmarc:sa"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d110">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="corporate-name">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="corporate-location">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sd">
          <pz:metadata type="corporate-date">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d111">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="meeting-name">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="meeting-location">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sd">
          <pz:metadata type="meeting-date">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d260">
        <xsl:for-each select="tmarc:sd">
          <pz:metadata type="date">
            <xsl:value-of select="translate(tmarc:sc, 'cp[].', '')"/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:if test="string-length($date_008) &gt; 0 and not(tmarc:d260)">
        <pz:metadata type="date">
          <xsl:choose>
            <xsl:when test="$date_end_008">
              <xsl:value-of select="concat($date_008,'-',$date_end_008)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$date_008"/>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:if>

      <xsl:for-each select="tmarc:d130">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="title-uniform">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sm">
          <pz:metadata type="title-uniform-media">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sn">
          <pz:metadata type="title-uniform-parts">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sp">
          <pz:metadata type="title-uniform-partname">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sr">
          <pz:metadata type="title-uniform-key">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d245">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="title">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sb">
          <pz:metadata type="title-remainder">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="title-responsibility">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sf">
          <pz:metadata type="title-dates">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sh">
          <pz:metadata type="title-medium">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:variable name="number-info">
          <xsl:for-each select="tmarc:sn|tmarc:sp">
            <xsl:value-of select="."/>
            <xsl:if test="not(contains(',.;:' ,substring(., string-length(.), 1)))">
              <xsl:choose>
                <xsl:when test="name(.)='sn' and name(following-sibling::*[1])='sp'">
                  <xsl:text>:</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>.</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </xsl:variable>
        <pz:metadata type="title-number-section">
          <xsl:value-of select="$number-info"/>
        </pz:metadata>
        <pz:metadata type="title-complete">
          <xsl:value-of select="tmarc:sa"/>
          <xsl:if test="tmarc:sn|tmarc:sp">
            <xsl:value-of select="concat(' ', $number-info)"/>
          </xsl:if>
          <xsl:if test="tmarc:sb">
            <xsl:value-of select="concat(': ', tmarc:sb)"/>
          </xsl:if>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d250">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="edition">
            <xsl:value-of select="tmarc:sa"/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <!-- Map information:
           Create the mapscale field, add the scale as its text and
           the projection/coordinates fields as attributes.
           Delete the brackets and punctuation surrounding the
           coordinates string.
      -->
      <xsl:for-each select="tmarc:d255">
        <pz:metadata type="mapscale">
          <xsl:if test="tmarc:sb">
            <xsl:attribute name="projection">
              <xsl:value-of select="tmarc:sb"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="tmarc:sc">
            <xsl:attribute name="coordinates">
              <xsl:value-of select="translate(tmarc:sc, '().', '')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="tmarc:sa"/>
       </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d260">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="publication-place">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sb">
          <pz:metadata type="publication-name">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="publication-date">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d300">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="physical-extent">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sb">
          <pz:metadata type="physical-format">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sc">
          <pz:metadata type="physical-dimensions">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:se">
          <pz:metadata type="physical-accomp">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sf">
          <pz:metadata type="physical-unittype">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sg">
          <pz:metadata type="physical-unitsize">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:s3">
          <pz:metadata type="physical-specified">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d440">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="series-title">
            <xsl:value-of select="." />
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <!--
        If the multipart variable (leader position 19) is b, the first Field 490
        contains the multivolume work title. If the multivolume work is part of a series,
        the series will be stated in the following 490 field.
      -->
      <xsl:for-each select="tmarc:d490">
        <xsl:choose>
          <xsl:when test="$multipart = 'b' and position() = 1">
            <pz:metadata type="multivolume-title">
              <xsl:value-of select="tmarc:sa"/>
              <xsl:if test="tmarc:sv">
                <xsl:text> </xsl:text>
                <xsl:value-of select="tmarc:sv"/>
              </xsl:if>
            </pz:metadata>
          </xsl:when>
          <xsl:otherwise>
            <pz:metadata type="series-title">
              <xsl:value-of select="tmarc:sa"/>
              <xsl:if test="tmarc:sv">
                <xsl:text> </xsl:text>
                <xsl:value-of select="tmarc:sv"/>
              </xsl:if>
            </pz:metadata>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <!-- Note fields
           [general/500, with/501, dissertation/502, formatted contents/505,
            event/518, summary/520, geographic coverage/522]
           Concatenate their values with commas in between and write a description field.
           Ignore abstracts (520 with i1=3) which are treated separately below.
      -->
      <xsl:for-each select="tmarc:d500 | tmarc:d501 | tmarc:d502 | tmarc:d505 |
                            tmarc:d518 | tmarc:d520[@i1!='3'] | tmarc:d522">
        <pz:metadata type="description">
          <xsl:for-each select="./*">
            <xsl:value-of select="text()"/>
            <xsl:if test="position()!=last() and .!=''">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <!-- Corporate name (710) or meeting name (711):
           Join the (non-control) subfields of these fields with spaces
           as separators so they are reasonably legible and write into
           a description field.
      -->
      <xsl:for-each select="tmarc:d710 | tmarc:d711">
        <pz:metadata type="description">
          <xsl:for-each select="./*[local-name() != 's0' and local-name() != 's3'
                                    and local-name() != 's5' and local-name() != 's6'
                                    and local-name() != 's8']">
            <xsl:value-of select="text()"/>
            <xsl:if test="position()!=last() and .!=''">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <!-- Abstracts (520 with i1=3) get their own metadata field.
           They are explicitly excluded from becoming descriptions above.
      -->
      <xsl:for-each select="tmarc:d520[@i1='3']">
        <pz:metadata type="abstract">
          <xsl:for-each select="./*">
            <xsl:value-of select="text()"/>
            <xsl:if test="position()!=last() and .!=''">
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d911">
        <pz:metadata type="description">
          <xsl:for-each select="node()">
            <xsl:value-of select="text()"/>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d600 | tmarc:d610 | tmarc:d611 | tmarc:d630 |
                            tmarc:d648 | tmarc:d650 | tmarc:d651 | tmarc:d653 |
                            tmarc:d654 | tmarc:d655 | tmarc:d656 | tmarc:d657 |
                            tmarc:d658 | tmarc:d662 | tmarc:d690 | tmarc:d691 |
                            tmarc:d692 | tmarc:d693 | tmarc:d694 | tmarc:d696 |
                            tmarc:d697 | tmarc:d698 | tmarc:d699 | tmarc:d69X">
        <xsl:for-each select="tmarc:sa">
          <pz:metadata type="subject">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>

        <pz:metadata type="subject-long">
          <xsl:for-each select="node()/text()">
            <xsl:if test="position() &gt; 1">
              <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:variable name='value'>
              <xsl:value-of select='normalize-space(.)'/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="substring($value, string-length($value)) = ','">
                <xsl:value-of select="substring($value, 1, string-length($value)-1)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$value"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>


      <!--
        Grab potential parent-id from 800/810/830 $w.
        Parent links can occur in these fields (corresponding to the parent items mentioned
        in 490 fields or 245) as well as in 773 $w.
        There should be at most one parent-id.
      -->
      <xsl:for-each select="tmarc:d800 | tmarc:d810 | tmarc:d830">
        <xsl:if test="tmarc:sw">
          <pz:metadata type="parent-id">
            <xsl:value-of select="tmarc:sw"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <!-- Links: 856, with an attempt to try and isolate DOIs and URNs -->
      <xsl:for-each select="tmarc:d856">
        <xsl:choose>
          <xsl:when test="substring(tmarc:su, 1, 18) = 'http://dx.doi.org/'">
            <pz:metadata type="doi">
              <xsl:value-of select="substring-after(tmarc:su, 'http://dx.doi.org/')"/>
            </pz:metadata>
          </xsl:when>
          <xsl:when test="substring(tmarc:su, 1, 4) = 'urn:'">
            <pz:metadata type="urn">
              <xsl:value-of select="tmarc:su"/>
            </pz:metadata>
          </xsl:when>
          <xsl:otherwise>
            <pz:metadata type="electronic-url">
              <xsl:if test="tmarc:sy|tmarc:s3|tmarc:sa">
                <xsl:attribute name="name">
                  <xsl:choose>
                    <xsl:when test="tmarc:sy">
                      <xsl:value-of select="tmarc:sy"/>
                    </xsl:when>
                    <xsl:when test="tmarc:s3">
                      <xsl:value-of select="tmarc:s3"/>
                    </xsl:when>
                    <xsl:when test="tmarc:sa">
                      <xsl:value-of select="tmarc:sa"/>
                    </xsl:when>
                  </xsl:choose>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="tmarc:sz">
                <xsl:attribute name="note">
                  <xsl:value-of select="tmarc:sz"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="tmarc:si">
                <xsl:attribute name="format-instruction">
                  <xsl:value-of select="tmarc:si"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="tmarc:sq">
                <xsl:attribute name="format-type">
                  <xsl:value-of select="tmarc:sq"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:value-of select="tmarc:su"/>
            </pz:metadata>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d773">
        <!-- full citation -->
        <pz:metadata type="citation">
          <xsl:for-each select="*">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text> </xsl:text>
          </xsl:for-each>
        </pz:metadata>
        <!-- ISSN -->
        <xsl:if test="tmarc:sx">
          <pz:metadata type="issn">
            <xsl:value-of select="tmarc:sx"/>
          </pz:metadata>
        </xsl:if>
        <!-- ISBN, can appear for essays in a book -->
        <xsl:if test="tmarc:sz">
          <pz:metadata type="isbn">
            <xsl:value-of select="tmarc:sz"/>
          </pz:metadata>
        </xsl:if>
        <!-- title: $parent-title combines $a and $t -->
        <xsl:if test="$parent-title">
          <pz:metadata type="journal-title">
            <xsl:value-of select="$parent-title"/>
          </pz:metadata>
        </xsl:if>
        <!-- short title -->
        <xsl:if test="tmarc:sp">
          <pz:metadata type="journal-title-abbrev">
            <xsl:value-of select="tmarc:sp"/>
          </pz:metadata>
        </xsl:if>
        <!-- parent ID -->
        <xsl:if test="tmarc:sw">
          <pz:metadata type="parent-id">
            <xsl:value-of select="tmarc:sw"/>
          </pz:metadata>
        </xsl:if>

        <!-- if necessary evaluate volume/pages information from $g -->
        <xsl:if test="tmarc:sg">
          <xsl:variable name="subpart">
            <xsl:for-each select="tmarc:sg">
              <xsl:value-of select="."/>
              <xsl:text> </xsl:text>
            </xsl:for-each>
          </xsl:variable>

          <pz:metadata type="journal-subpart">
            <xsl:value-of select="normalize-space($subpart)"/>
          </pz:metadata>

          <xsl:if test="not(tmarc:sq)">
            <xsl:variable name="l">
              <xsl:value-of select="translate($subpart,
                                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ.',
                                   'abcdefghijklmnopqrstuvwxyz ')"/>
            </xsl:variable>
            <xsl:variable name="volume">
              <xsl:choose>
                <xsl:when test="string-length(substring-after($l,'vol ')) &gt; 0">
                  <xsl:value-of select="substring-before(normalize-space(substring-after($l,'vol ')),' ')"/>
                </xsl:when>
                <xsl:when test="string-length(substring-after($l,'v ')) &gt; 0">
                  <xsl:value-of select="substring-before(normalize-space(substring-after($l,'v ')),' ')"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="issue">
              <xsl:value-of select="substring-before(translate(normalize-space(substring-after($l,'issue')), ',', ' '),' ')"/>
            </xsl:variable>
            <xsl:variable name="pages">
              <xsl:choose>
                <xsl:when test="string-length(substring-after($l,' p ')) &gt; 0">
                  <xsl:value-of select="normalize-space(substring-after($l,' p '))"/>
                </xsl:when>
                <xsl:when test="string-length(substring-after($l,',p')) &gt; 0">
                  <xsl:value-of select="normalize-space(substring-after($l,',p'))"/>
                </xsl:when>
                <xsl:when test="string-length(substring-after($l,' p')) &gt; 0">
                  <xsl:value-of select="normalize-space(substring-after($l,' p'))"/>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <!-- volume -->
            <xsl:if test="string-length($volume) &gt; 0">
              <pz:metadata type="volume-number">
                <xsl:value-of select="$volume"/>
              </pz:metadata>
            </xsl:if>
            <!-- issue -->
            <xsl:if test="string-length($issue) &gt; 0">
              <pz:metadata type="issue-number">
                <xsl:value-of select="$issue"/>
              </pz:metadata>
            </xsl:if>
            <!-- pages -->
            <xsl:if test="string-length($pages) &gt; 0">
              <pz:metadata type="pages-number">
                <xsl:value-of select="$pages"/>
              </pz:metadata>
            </xsl:if>
          </xsl:if> <!-- not(tmarc:sq) -->
        </xsl:if> <!-- tmarc:sg -->

        <!--
          Evaluate Marc 773 $q for article page numbers.
          The field contains a string of the form
            volume:issue:subissue<pagenumber
            ..1...:......2.......<....3.....
          where each component is potentially optional and the depth of the subissue
          hierarchy can be extended as needed. Map the components to the pz:metadata fields:
            1: volume-number
            2: issue-number
            3: pages
          omitting blank fields if they occur.
        -->
        <xsl:if test="tmarc:sq">
          <xsl:variable name="volumeIssue">
            <xsl:choose>
              <xsl:when test="contains(tmarc:sq, '&lt;')">
                <xsl:value-of select="substring-before(tmarc:sq, '&lt;')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="tmarc:sq"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="volume">
            <xsl:choose>
              <xsl:when test="contains($volumeIssue, ':')">
                <xsl:value-of select="normalize-space(substring-before($volumeIssue, ':'))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="normalize-space($volumeIssue)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="issue" select="normalize-space(substring-after($volumeIssue, ':'))"/>
          <xsl:variable name="pages" select="normalize-space(substring-after(tmarc:sq, '&lt;'))"/>

          <!-- volume -->
          <xsl:if test="string-length($volume) &gt; 0">
            <pz:metadata type="volume-number">
              <xsl:value-of select="$volume"/>
            </pz:metadata>
          </xsl:if>
          <!-- issue -->
          <xsl:if test="string-length($issue) &gt; 0">
            <pz:metadata type="issue-number">
              <xsl:value-of select="$issue"/>
            </pz:metadata>
          </xsl:if>
          <!-- pages -->
          <xsl:if test="string-length($pages) &gt; 0">
            <pz:metadata type="pages-number">
              <xsl:value-of select="$pages"/>
            </pz:metadata>
          </xsl:if>
        </xsl:if> <!-- tmarc:sq -->

      </xsl:for-each> <!-- tmarc:d773 -->

      <xsl:for-each select="tmarc:d852">
        <xsl:for-each select="tmarc:sy">
          <pz:metadata type="publicnote">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
        <xsl:for-each select="tmarc:sh">
          <pz:metadata type="callnumber">
            <xsl:value-of select="."/>
          </pz:metadata>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d876">
        <xsl:if test="tmarc:sf">
          <pz:metadata type="loan-period">
            <xsl:value-of select="concat(tmarc:s5,':',tmarc:sf)"/>
          </pz:metadata>
        </xsl:if>
      </xsl:for-each>

      <pz:metadata type="medium">
        <xsl:value-of select="$vmedium"/>
        <xsl:if test="string-length($electronic) and $vmedium != 'electronic'">
          <xsl:text> (electronic)</xsl:text>
        </xsl:if>
      </pz:metadata>

      <xsl:for-each select="tmarc:d900">
        <pz:metadata type="fulltext">
          <xsl:for-each select="tmarc:sa | tmarc:sb | tmarc:se | tmarc:sf |
                              tmarc:si | tmarc:sk | tmarc:sk | tmarc:sq |
                              tmarc:ss | tmarc:su | tmarc:sy">
            <xsl:value-of select="."/>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <pz:metadata type="has-fulltext">
        <xsl:value-of select="$has_fulltext"/>
      </pz:metadata>

      <xsl:for-each select="tmarc:d907 | tmarc:d901">
        <pz:metadata type="iii-id">
          <xsl:value-of select="tmarc:sa"/>
        </pz:metadata>
      </xsl:for-each>
      <xsl:for-each select="tmarc:d926">
        <pz:metadata type="locallocation">
          <xsl:choose>
            <xsl:when test="tmarc:sa">
              <xsl:value-of select="tmarc:sa"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>PAZPAR2_NULL_VALUE</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
        <pz:metadata type="callnumber">
          <xsl:choose>
            <xsl:when test="tmarc:sc">
              <xsl:value-of select="tmarc:sc"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>PAZPAR2_NULL_VALUE</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
        <pz:metadata type="available">
          <xsl:choose>
            <xsl:when test="tmarc:se">
              <xsl:value-of select="tmarc:se"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>PAZPAR2_NULL_VALUE</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:for-each>

      <!-- OhioLINK holdings -->
      <xsl:for-each select="tmarc:d945">
        <pz:metadata type="locallocation">
          <xsl:choose>
            <xsl:when test="tmarc:sa">
              <xsl:value-of select="tmarc:sa"/>
            </xsl:when>
            <xsl:otherwise>PAZPAR2_NULL_VALUE</xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
        <pz:metadata type="callnumber">
          <xsl:choose>
            <xsl:when test="tmarc:sb">
              <xsl:value-of select="tmarc:sb"/>
            </xsl:when>
            <xsl:otherwise>PAZPAR2_NULL_VALUE</xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
        <pz:metadata type="publicnote">
          <xsl:choose>
            <xsl:when test="tmarc:sc">
              <xsl:value-of select="tmarc:sc"/>
            </xsl:when>
            <xsl:otherwise>PAZPAR2_NULL_VALUE</xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
        <pz:metadata type="available">
          <xsl:choose>
            <xsl:when test="tmarc:ss = 'N'">Available</xsl:when>
            <xsl:when test="tmarc:ss != 'N'">
              <xsl:choose>
                <xsl:when test="tmarc:sd">
                  <xsl:value-of select="tmarc:sd"/>
                </xsl:when>
                <xsl:otherwise>PAZPAR2_NULL_VALUE</xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>PAZPAR2_NULL_VALUE</xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d948 | tmarc:d991">
        <pz:metadata type="holding">
          <xsl:for-each select="tmarc:s">
            <xsl:if test="position() &gt; 1">
              <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
          </xsl:for-each>
        </pz:metadata>
      </xsl:for-each>

      <xsl:for-each select="tmarc:d999">
        <pz:metadata type="localid">
          <xsl:choose>
            <xsl:when test="tmarc:sa">
              <xsl:value-of select="tmarc:sa"/>
            </xsl:when>
            <xsl:when test="tmarc:sc">
              <xsl:value-of select="tmarc:sc"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="tmarc:sd"/>
            </xsl:otherwise>
          </xsl:choose>
        </pz:metadata>
      </xsl:for-each>

      <!-- passthrough id data -->
      <xsl:for-each select="pz:metadata">
        <xsl:copy-of select="."/>
      </xsl:for-each>

      <!-- other stylesheets importing this might want to define this -->
      <xsl:call-template name="record-hook"/>

    </pz:record>
  </xsl:template>

  <xsl:template match="text()" />

</xsl:stylesheet>
