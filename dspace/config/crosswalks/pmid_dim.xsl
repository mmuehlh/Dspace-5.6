<?xml version="1.0"?>
<xsl:stylesheet
        		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
		    xmlns:fn="http://www.w3.org/2005/02/xpath-functions"	
                version="1.0">
                
<xsl:output indent="yes" method="xml" />                  

<xsl:template match="/"> 
	<dim:dim>  
		<xsl:apply-templates />
	<!--	<xsl:call-template name="citation" /> -->
                <dim:field element="type" mdschema="dc">journalArticle</dim:field>
                <dim:field element="type" qualifier="version" mdschema="dc">publishedVersion</dim:field>

	</dim:dim>
</xsl:template>	
						  
<xsl:template match ="PubmedArticle/MedlineCitation/PMID">
	<dim:field element="identifier" qualifier="pmid" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
</xsl:template>	
	
<xsl:template match="PubmedArticle/MedlineCitation/Article/ArticleTitle">
	<dim:field element="title" mdschema="dc">
		<xsl:value-of select ="."/>
	</dim:field>

</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/Volume" >
	<dim:field element="bibliographicCitation" qualifier="volume" mdschema="dc">
	<xsl:value-of select ="."/>
	</dim:field>
</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/Issue" >
	<dim:field element="bibliographicCitation" qualifier="issue" mdschema="dc">
	<xsl:value-of select ="."/>
	</dim:field>
			
</xsl:template>

<xsl:template mode="citation" match="PubmedArticle/MedlineCitation/Article/Pagination/MedlinePgn" >
	<xsl:text>, p. </xsl:text>
	<xsl:value-of select ="."/>
</xsl:template>

<xsl:template mode="citation" match="PubmedArticle/MedlineCitation/Article/Journal/ISOAbbreviation" >
	<xsl:text> </xsl:text>
	<xsl:value-of select="."/>
</xsl:template>

<xsl:template mode="citation" match="PubmedArticle/MedlineCitation/MedlineJournalInfo/MedlineTA">
	<xsl:choose>
		<xsl:when test="../../Article/Journal/ISOAbbreviation" >
			<!-- do nothing...it has already been appended to the citation -->
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>not</xsl:text>
			<xsl:value-of select="."/>
		</xsl:otherwise>
	</xsl:choose>	
</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/Pagination/MedlinePgn" >
  <xsl:choose>
	<xsl:when test="contains(//Pagination/MedlinePgn, '-') ">
	  <dim:field element="bibliographicCitation" qualifier="firstPage" mdschema="dc">
	    <xsl:value-of select ="substring-before(.,'-') "/>
	  </dim:field>
	  <dim:field element="bibliographicCitation" qualifier="lastPage" mdschema="dc">
	    <xsl:value-of select ="substring-after(.,'-') "/>
	  </dim:field>
	</xsl:when>
	<xsl:otherwise>
	  <dim:field element="bibliographicCitation" qualifier="firstPage" mdschema="dc">
	    <xsl:value-of select ="."/>
	  </dim:field>
	  <dim:field element="bibliographicCitation" qualifier="lastPage" mdschema="dc">
	    <xsl:value-of select ="."/>
	  </dim:field>
	</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/Journal/ISSN" >
	<dim:field element="relation" qualifier="issn" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/Abstract" >
	<dim:field element="description" qualifier="abstract" mdschema="dc" >
	   <xsl:for-each select="AbstractText">
	     <xsl:if test="@Label">
		<xsl:value-of select="@Label" /><xsl:text>: </xsl:text>
	     </xsl:if>
		<xsl:value-of select ="." />
		<xsl:text>
		</xsl:text>
	   </xsl:for-each>
	</dim:field>
</xsl:template>

<xsl:template match="PubmedArticle/PubmedData/ArticleIdList/ArticleId[@IdType = 'doi']">
	<dim:field element="identifier" qualifier ="doi" mdschema="dc">
		<xsl:value-of select ="." />
	</dim:field>
</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/Journal/Title">
	<dim:field element="relation" qualifier ="ispartofseries" mdschema="dc">
		<xsl:value-of select ="." />
	</dim:field>
</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/Journal/JournalIssue/PubDate" >
	<xsl:variable name ="pubdate" >
		<xsl:apply-templates  mode="format_date" select="." />
	</xsl:variable>
	<dim:field element="date" qualifier="issued" mdschema="dc">
		<xsl:value-of select ="$pubdate" />
	</dim:field>

</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/Language" >
	<xsl:choose>
		<xsl:when test="//Language = 'ENG' " >
			<dim:field element="language" qualifier="iso" mdschema="dc">
				<xsl:text>en</xsl:text>
			</dim:field>
		</xsl:when>
		<xsl:otherwise >
			<dim:field element="language" >
				<xsl:value-of select="." />
			</dim:field>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/Article/AuthorList">
  <xsl:for-each select="Author">
	<xsl:if test= "*[local-name() = 'LastName']" >
		<dim:field element = "contributor" qualifier="author"  mdschema="dc">
			<xsl:value-of select="*[local-name()='LastName']" />
			<xsl:choose>
				<xsl:when test= "*[local-name() = 'ForeName']" >
					<xsl:text>, </xsl:text>
					<xsl:value-of select = "*[local-name() = 'ForeName']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="*[local-name() = 'Initials']">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="*[local-name() = 'Initials']" />
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</dim:field>
	</xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template name="citation">
	<dim:field element ="identifier" qualifier="citation" mdschema="dc">
	   <!--<xsl:value-of select="PubmedArticle/MedlineCitation/Article/AuthorList"/> --> 
	    <xsl:for-each select="//Author">
			<xsl:value-of select="*[local-name()='LastName']" />
			<xsl:choose>
				<xsl:when test= "*[local-name() = 'ForeName']" >
					<xsl:text>, </xsl:text>
					<xsl:value-of select = "*[local-name() = 'ForeName']" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="*[local-name() = 'Initials']">
						<xsl:text>, </xsl:text>
						<xsl:value-of select="*[local-name() = 'Initials']" />
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>	
			<xsl:if test="position() != last()">
			    <xsl:text>; </xsl:text>
			</xsl:if>
	      </xsl:for-each>

		<xsl:if test="//Journal/JournalIssue/PubDate/Year" >
			<xsl:text> (</xsl:text>
			<xsl:value-of select="//Journal/JournalIssue/PubDate/Year" />
			<xsl:text>): </xsl:text>
		</xsl:if>
		<xsl:value-of select="//Article/ArticleTitle" />
		<xsl:text> - </xsl:text>
		<xsl:value-of select="//Article/Journal/Title" />
		<xsl:if test="//Journal/JournalIssue/Volume">
		    <xsl:value-of select="concat(', Vol. ',//Journal/JournalIssue/Volume)" />
		</xsl:if>
		<xsl:if test="//Journal/JournalIssue/Issue">
		    <xsl:value-of select="concat(', Nr. ',//Journal/JournalIssue/Issue)" />
		</xsl:if>
		<xsl:if test="//Pagination/MedlinePgn">
		    <xsl:value-of select="concat(', p. ',//Pagination/MedlinePgn)" />
		</xsl:if>
		<!-- <xsl:apply-templates mode="citation" select="../../MedlineJournalInfo/MedlineTA" /> -->
	</dim:field>
</xsl:template>

<xsl:template match="PubmedArticle/MedlineCitation/MeshHeadingList/MeshHeading/DescriptorName" >
	<dim:field element="subject" qualifier="mesh" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
</xsl:template>

<!-- 
<xsl:template match ="PubmedArticle/MedlineCitation/Article" >
	<xsl:if test ="*[local-name() = 'ArticleTitle']" >
		<dim:field element ="identifier" qualifier="citation">
			<xsl:value-of select ="*[local-name() = 'ArticleTitle']" />
			<xsl:apply-templates mode="citation" select="./Journal/JournalIssue/PubDate/Year" />
			<xsl:apply-templates mode="citation" select="./Journal/JournalIssue/Volume" />
			<xsl:apply-templates mode="citation" select="./Journal/JournalIssue/Issue" />
			<xsl:apply-templates mode="citation" select="./Pagination/MedlinePgn" />
			<xsl:apply-templates mode="citation1" select="./Journal/ISOAbbreviation" />
		</dim:field>
	</xsl:if>
</xsl:template>
 -->

<xsl:template mode="citation" match="*" >
	<xsl:choose>
		<xsl:when test="*[local-name() = 'Year']">
			<xsl:text> </xsl:text>
			<xsl:value-of select="." />
		</xsl:when>
		<xsl:when  test="*[local-name() = 'Volume']">
			<xsl:text>, </xsl:text>
			<xsl:value-of select="." />
		</xsl:when>
		<xsl:when test="*[local-name() = 'Issue']">
			<xsl:text> (</xsl:text>
			<xsl:value-of select="." />
			<xsl:text>)</xsl:text>
		</xsl:when>
		<xsl:when test="*[local-name() = 'MedlinePgn']" >
			<xsl:text>:</xsl:text>
			<xsl:value-of select ="."/>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template mode="format_date" match="*">
	<xsl:if test ="*[local-name()='Year']">
		<xsl:value-of select="*[local-name()='Year']" />
	</xsl:if> 
	<xsl:if test="*[local-name() = 'Month']">
		<xsl:text>-</xsl:text>
		<xsl:variable name="monthNum" >
			<xsl:call-template name='monthToNum'>
				<xsl:with-param name="month" select="*[local-name() = 'Month']" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="format-number($monthNum,'00')" />
	</xsl:if>
	<xsl:if test ="*[local-name() = 'Day']" >
		<xsl:text>-</xsl:text>
		<xsl:value-of select="format-number(number(*[local-name() = 'Day']),'00')" />
	</xsl:if>
</xsl:template>

<!-- This will override the default text() functionality, so unmatched values are not 
	 included -->
<xsl:template match="text()" >
</xsl:template>


<xsl:template name="monthToNum">
<xsl:param name="month" />
	<xsl:choose>
	<xsl:when test="$month ='Jan'">
		<xsl:text>1</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Feb'">
		<xsl:text>2</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Mar'">
		<xsl:text>3</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Apr'">
		<xsl:text>4</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='May'">
		<xsl:text>5</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Jun'">
		<xsl:text>6</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Jul'">
		<xsl:text>7</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Aug'">
		<xsl:text>8</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Sep'">
		<xsl:text>9</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Oct'">
		<xsl:text>10</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Nov'">
		<xsl:text>11</xsl:text>
	</xsl:when>
	<xsl:when test="$month ='Dec'">
		<xsl:text>12</xsl:text>
	</xsl:when>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>

