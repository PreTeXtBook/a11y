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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="exsl date str"
    xmlns:pi="http://pretextbook.org/2020/pretext/internal"
    xmlns:math="http://www.w3.org/1998/Math/MathML"
>

<!-- get visible ids to track correspondence -->
<xsl:import href="/home/rob/mathbook/mathbook/xsl/pretext-common.xsl" />

<!-- Building JSON, so not XML/HTML, etc.-->
<xsl:output method="text"/>

<!-- Necessary to get pre-constructed MathML for math elements. -->
<xsl:param name="mml-file" select="''"/>
<xsl:variable name="math-repr"  select="document($mml-file)/pi:math-representations"/>


<!-- ############## -->
<!-- Entry Template -->
<!-- ############## -->

<!-- Deprecation warnings are universal analysis of source and parameters  -->
<!-- There is always a "document root" directly under the pretext element, -->
<!-- Note that "docinfo" is at the same level and not processed            -->
<xsl:template match="/">
    <xsl:text>{&#xa;</xsl:text>
    <xsl:text>  "factory": "</xsl:text><xsl:text>Not Sure</xsl:text><xsl:text>",&#xa;</xsl:text>
    <xsl:text>  "exclude": "</xsl:text><xsl:text>[]</xsl:text><xsl:text>",&#xa;</xsl:text>
    <xsl:text>  "tests":&#xa;</xsl:text>
    <xsl:text>    {&#xa;</xsl:text>
    <xsl:apply-templates select="pretext/article/p/ol/li/m"/>
    <xsl:text>    }&#xa;</xsl:text>
    <xsl:text>}&#xa;</xsl:text>
</xsl:template>

<xsl:template match="m">
    <!-- to sync two files of the same content -->
    <xsl:variable name="common-id">
        <xsl:apply-templates select="." mode="visible-id"/>
    </xsl:variable>

    <xsl:variable name="math" select="$math-repr/pi:math[@id = $common-id]"/>

    <xsl:variable name="mathml">
        <xsl:call-template name="escape-json-string">
            <xsl:with-param name="text">
                <xsl:apply-templates select="$math/div[@class = 'mathml']/math:math" mode="serialize"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>

    <!-- Sanitize raw LaTeX as JSON for the test -->
    <xsl:variable name="raw-latex">
        <xsl:call-template name="sanitize-text">
            <xsl:with-param name="text">
                <xsl:value-of select="."/>
            </xsl:with-param>
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
    <xsl:variable name="test-name">
        <xsl:text>Test </xsl:text>
        <xsl:value-of select="count(parent::li/preceding-sibling::li) + 1"/>
    </xsl:variable>

    <xsl:text>    "</xsl:text><xsl:value-of select="$test-name"/><xsl:text>": {&#xa;</xsl:text>
    <xsl:text>      "id": "</xsl:text><xsl:value-of select="$common-id"/><xsl:text>",&#xa;</xsl:text>
    <xsl:text>      "input": "</xsl:text><xsl:value-of select="$mathml"/><xsl:text>",&#xa;</xsl:text>
    <xsl:text>      "tex": "</xsl:text><xsl:value-of select="$escaped-latex"/><xsl:text>",&#xa;</xsl:text>
    <xsl:text>      "expected": "</xsl:text><xsl:text>"&#xa;</xsl:text>
    <xsl:text>      }</xsl:text>
    <xsl:if test="parent::li/following-sibling::li">
        <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>


</xsl:stylesheet>