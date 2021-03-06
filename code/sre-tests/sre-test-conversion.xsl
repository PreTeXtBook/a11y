<?xml version='1.0'?> <!-- As XML file -->

<!--********************************************************************
Copyright 2013-2020 Robert A. Beezer

This file is part of PreTeXt.

PreTeXt is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 or version 3 of the
License (at your option).

PreTeXt is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with PreTeXt.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************-->

<!-- Identify as a stylesheet -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Get visible ids to track correspondence and for subsequent -->
<!-- identification.  Also a base URL ($baseurl) is generated   -->
<!-- by the publisher variables suite.                          -->
<!-- NB: path is hard-coded, the "mathbook/user" directory      -->
<!-- device can be used if this needs to be a relative URL      -->
<!-- for use by others                                          -->
<xsl:import href="/home/rob/mathbook/mathbook/xsl/pretext-common.xsl" />

<!-- Every conversion should run the pre-processor -->
<xsl:import href="/home/rob/mathbook/mathbook/xsl/pretext-assembly.xsl" />


<!-- Building JSON, so not XML/HTML, etc., XSL -->
<!-- cannot infer JSON structure for output    -->
<xsl:output method="text"/>

<!-- To extract from a single PreTeXt document                                                     -->
<!--                                                                                               -->
<!--   * -xinclude necessary for modular source                                                    -->
<!--   * publisher file to get base URL for HTML truth/context                                     -->
<!--     (relative path to main source location)                                                   -->
<!--   * chunking level so HTML output file names are correct                                      -->
<!--     (moving very soon to publisher file)                                                      -->
<!--   * redirect output to JSON file                                                              -->
<!--                                                                                               -->
<!-- 
xsltproc -xinclude -stringparam publisher ../publisher/public.xml -stringparam chunk.level 2 ~/mathbook/repos/a11y/code/sre-tests/sre-test-conversion.xsl ~/books/aata/aata/src/aata.xml > aata-tests.json
-->

<!-- NB: we should really run the pre-processor, -->
<!-- for example to pick up WW problems in ACS   -->

<!-- HTML is "chunked" for output and we create URLS into -->
<!-- posted/hosted HTML so that mathematical expressions  -->
<!-- can be viewed in context as a sort of ground truth   -->
<xsl:variable name="file-extension" select="'.html'"/>
<xsl:variable name="chunk-level" select="$chunk-level-entered"/>

<!-- Entry Template -->
<!-- A node-set of all teh math will be useful               -->
<!-- $document-root is set in routines in -common and will   -->
<!-- avoid finding anything in $docinfo                      -->
<xsl:variable name="math-bits" select="$document-root//m|$document-root//me|$document-root//men|$document-root//md|$document-root//mdn"/>

<!-- Minimal outer JSON structure, just a list full of tests -->
<!-- Start here and simply match on mathematics of interest  -->
<xsl:template match="/">
    <xsl:text>[&#xa;</xsl:text>
    <xsl:call-template name="place-macros"/>
    <xsl:variable name="all-math-extra-comma">
        <xsl:apply-templates select="$math-bits"/>
    </xsl:variable>
    <!-- scrub trailing comma, JSON!!!, newline in the way -->
    <xsl:value-of select="concat(substring($all-math-extra-comma, 1, string-length($all-math-extra-comma) - 2), '&#xa;')"/>
    <xsl:text>]&#xa;</xsl:text>
</xsl:template>

<!-- These skip solutions to activities in ACS, which are not shown online -->
<xsl:template match="m[ancestor::activity and (ancestor::hint|ancestor::answer|ancestor::solution)]"/>
<xsl:template match="me[ancestor::activity and (ancestor::hint|ancestor::answer|ancestor::solution)]"/>
<xsl:template match="men[ancestor::activity and (ancestor::hint|ancestor::answer|ancestor::solution)]"/>
<xsl:template match="md[ancestor::activity and (ancestor::hint|ancestor::answer|ancestor::solution)]"/>
<xsl:template match="mdn[ancestor::activity and (ancestor::hint|ancestor::answer|ancestor::solution)]"/>

<xsl:template name="place-macros">
    <xsl:text>   {&#xa;</xsl:text>
    <xsl:text>     "macros": "</xsl:text>
    <!--  -->
    <xsl:call-template name="escape-json-string">
        <xsl:with-param name="text">
            <xsl:value-of select="$latex-macros"/>
        </xsl:with-param>
    </xsl:call-template>
    <!--  -->
    <xsl:text>"&#xa;</xsl:text>
    <xsl:text>   },&#xa;</xsl:text>
</xsl:template>


<!-- ################################################# -->
<!-- Adjustments to math-processing and LaTeX creation -->
<!-- ################################################# -->

<!-- We have imported -common, set inline delimiters to null, use     -->
<!-- switch to turn off inserting periods, and then apply templates   -->
<!-- to the math elements.  We hard-code tags for numbered equations. -->

<!-- No delimiters for inline in JSON, so implement as no-ops -->
<xsl:template name="begin-inline-math"/>
<xsl:template name="end-inline-math"/>
<!-- Solo items in list items don't get display treatment -->
<xsl:param name="debug.displaystyle" select="'no'"/>
<!-- Don't look forward for period, comma, etc.  Ever -->
<xsl:template match="m|me|men|md|mdn" mode="get-clause-punctuation"/>
<!-- Hard-code tags, always original, so ignore parameter -->
<xsl:template match="men|mrow" mode="tag">
    <xsl:text>\tag{</xsl:text>
    <xsl:apply-templates select="." mode="number" />
    <xsl:text>}</xsl:text>
</xsl:template>
<xsl:template match="mrow[@tag]" mode="tag">
    <xsl:text>\tag{</xsl:text>
    <xsl:apply-templates select="@tag" mode="tag-symbol" />
    <xsl:text>}</xsl:text>
</xsl:template>


<!-- ################################################# -->
<!-- Process math elements                             -->
<!-- ################################################# -->


<!-- N.B. Constructing a node-set to course over with a "for-each" -->
<!-- might make it more efficient to look forward for necessity    -->
<!-- of the comma separating each expression's output.             -->

<xsl:template match="m|me|men|md|mdn">
    <!-- We build up a few variables, so we can construct   -->
    <!-- JSON itself at the end and get formatting correct. -->

    <!-- Unique identifier for the math -->
    <xsl:variable name="visible-id">
        <xsl:apply-templates select="." mode="visible-id"/>
    </xsl:variable>

    <!-- JSON flag for display math versus no -->
    <xsl:variable name="is-display-math">
        <xsl:choose>
            <xsl:when test="self::m">
                <xsl:text>false</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>true</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- For the impatient - progress indicator on console -->
    <xsl:message><xsl:value-of select="$visible-id"/></xsl:message>

    <!-- Look outward for an item with a @permid attribute, -->
    <!-- typically a paragraph.  Consider that some math is -->
    <!-- in "born hidden" knowls, so a filter like          -->
    <!-- [not(ancestor::proof)] can be employed.            -->
    <!--  -->
    <!-- 1. "m" are not given @permid, so need to look outward           -->
    <!-- 2. displaymath *do* have @permid, but are not given an HTML @id -->
    <!-- Convert "self::" to "ancestor-or-self::" to enable better       -->
    <!-- targeting should we add an HTML id to a PreTeXt HTML            -->
    <!-- output displaymath div                                          -->
    <xsl:variable name="enclosing-permid-node" select="ancestor::*[@permid][1]"/>
    <xsl:variable name="enclosing-permid" select="$enclosing-permid-node/@permid"/>
    <!-- Borrow routines in -common really meant for HTML   -->
    <!-- and other chunked output. Santize for use in JSON. -->
    <xsl:variable name="online-URL">
        <xsl:call-template name="escape-json-string">
            <xsl:with-param name="text">
                <!-- base URL has a trailing slash, as manufactured -->
                <xsl:value-of select="$baseurl"/>
                <xsl:apply-templates select="$enclosing-permid-node" mode="containing-filename"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$enclosing-permid"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>

    <!-- inline is a straight match, via apply-imports  -->
    <!-- display needs modal call (which is wrong/bad?) -->
    <xsl:variable name="well-formed-latex">
        <xsl:choose>
            <xsl:when test="self::m">
                <xsl:apply-imports select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="body"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Sanitize raw LaTeX as JSON -->
    <xsl:variable name="raw-latex">
        <xsl:call-template name="sanitize-text">
            <xsl:with-param name="text" select="$well-formed-latex"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="sans-terminal-newline" select="substring($raw-latex, 1, string-length($raw-latex) - 1)"/>
    <xsl:variable name="escaped-latex">
        <xsl:call-template name="escape-json-string">
            <xsl:with-param name="text">
                <xsl:value-of select="$sans-terminal-newline"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>

    <!-- Output one expression as JSON -->
    <xsl:text>   {&#xa;</xsl:text>
    <xsl:text>     "id": "</xsl:text><xsl:value-of select="$visible-id"/><xsl:text>",&#xa;</xsl:text>
    <xsl:text>     "display": </xsl:text><xsl:value-of select="$is-display-math"/><xsl:text>,&#xa;</xsl:text>
    <xsl:text>     "url": "</xsl:text><xsl:value-of select="$online-URL"/><xsl:text>",&#xa;</xsl:text>
    <xsl:text>     "tex": "</xsl:text><xsl:value-of select="$escaped-latex"/><xsl:text>"&#xa;</xsl:text>
    <xsl:text>   },&#xa;</xsl:text>
</xsl:template>

</xsl:stylesheet>