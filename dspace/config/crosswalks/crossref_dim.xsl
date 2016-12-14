<?xml version="1.0"  encoding="utf-8"?>
<xsl:stylesheet
        	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
		xmlns:cref="http://www.crossref.org/xschema/1.1"
		xmlns:crf="http://www.crossref.org/xschema/1.0"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xsi:schemaLocation="http://www.crossref.org/schema/unixref1.1.xsd http://www.crossref.org/schema/unixref1.0.xsd"
                version="1.0"
		exclude-result-prefixes="cref crf xsi">
                
<xsl:output indent="yes" method="xml" />                  

<xsl:template match="text()"/>
<xsl:template match="/doi_records">
  
     <xsl:apply-templates  /> 
	
  
</xsl:template>

<xsl:template match="doi_record">
  
	<dim:dim> 
		<xsl:call-template name="newline" />
			<xsl:apply-templates  />
			
	<!--	<xsl:call-template name="article_citation0" />
		<xsl:call-template name="book_citation0" /> -->
	</dim:dim>

</xsl:template>	

<xsl:template match="crf:doi_record">
  
	<dim:dim> 
		<xsl:call-template name="newline" />
				<xsl:apply-templates  />
		
		<!-- <xsl:call-template name="article_citation1" />
		<xsl:call-template name="book_citation1" /> -->
	</dim:dim>

</xsl:template>	
						  
<xsl:template match ="crossref/journal/journal_article/doi_data/doi">
	<dim:field element="identifier" qualifier="doi" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
        <xsl:call-template name="newline" />
        <dim:field element="type" mdschema="dc">journalArticle</dim:field>
	<xsl:call-template name="newline" />	
	<dim:field element="type" qualifier="version" mdschema="dc">publishedVersion</dim:field>
        <xsl:call-template name="newline" />
</xsl:template>

<xsl:template match ="crossref/journal/journal_article/doi_data/timestamp">
    <!-- do nothing -->
</xsl:template>

<xsl:template match ="crossref/journal/journal_article/doi_data/resource">
    <!-- do nothing -->
</xsl:template>

<xsl:template match ="crossref/journal/journal_article/titles">
  <xsl:for-each select=".">
  <xsl:choose>
    <xsl:when test="position() = 1">
	<dim:field element="title" mdschema="dc">
		<xsl:value-of select="title" />
	</dim:field>
	<xsl:call-template name="newline" />
     </xsl:when>
     <xsl:otherwise>
        <dim:field element="title"  mdschema="dc">
                <xsl:value-of select="title" />
        </dim:field>
        <xsl:call-template name="newline" />
     </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
</xsl:template>	


<xsl:template match="issn[@media_type='electronic']" >
	<dim:field element="identifier" qualifier="issn" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>

<!-- <xsl:template match="issn[@media_type='print']" >
	<dim:field element="relation" qualifier="pISSN" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>
-->



<xsl:template match="crossref/journal/journal_article/publication_date" >
  <xsl:if test="@media_type='online'" >
	<dim:field element="date" qualifier="issued" mdschema="dc">
		<xsl:value-of select ="year" />
	</dim:field>
	<xsl:call-template name="newline" />
  </xsl:if>
  <xsl:if test="@media_type='print'" >
	<!-- do nothing -->
  </xsl:if>
</xsl:template>

<xsl:template match="crossref/journal/journal_issue/publication_date" >
  	<!-- do nothing -->
</xsl:template>


<xsl:template match="crossref/journal/journal_article/publisher_item" >
	<!-- do nothing -->
</xsl:template>

<xsl:template match="crossref/journal/journal_article/contributors/person_name">
    <xsl:for-each select=".">
	  <xsl:choose>
	    <xsl:when test="@contributor_role='author'">
		<dim:field element="contributor" qualifier="author"  mdschema="dc">
			<xsl:value-of select="concat(surname, ', ', given_name)" />

		</dim:field>
	<xsl:call-template name="newline" />
	    </xsl:when>
	    <xsl:otherwise>
		<dim:field element="contributor" qualifier="editor"  mdschema="dc">
		    	<xsl:value-of select="concat(surname, ', ', given_name)" />
		</dim:field>
	<xsl:call-template name="newline" />		
	    </xsl:otherwise>
	  </xsl:choose>
    </xsl:for-each>
</xsl:template>

<xsl:template name="article_citation0">
    <xsl:if test="crossref/journal/journal_article/contributors/person_name">
	<dim:field element ="identifier" qualifier="citation" mdschema="dc">

	    <xsl:for-each select="crossref/journal/journal_article/contributors/person_name" >
		<xsl:value-of select="concat(surname, ', ', given_name)" />
		<xsl:if test="position() != last()">
		  <xsl:text>; </xsl:text>
		</xsl:if>
	      </xsl:for-each>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="crossref/journal/journal_article/publication_date/year" />
		<xsl:text>): </xsl:text>
		<xsl:value-of select="crossref/journal/journal_article/titles/title" />
		<xsl:text> - </xsl:text>
		<xsl:value-of select="crossref/journal/journal_metadata/full_title" />
		<xsl:text>, Vol. </xsl:text>
		<xsl:value-of select="crossref/journal/journal_issue/journal_volume/volume" />
		<xsl:text>, Nr. </xsl:text>
		<xsl:value-of select="crossref/journal/journal_issue/issue" />
		<xsl:text>, p. </xsl:text>
		<xsl:value-of select="crossref/journal/journal_article/pages/first_page" />
		<xsl:text>-</xsl:text>
		<xsl:value-of select="crossref/journal/journal_article/pages/last_page" />
	</dim:field>
	<xsl:call-template name="newline" />
     </xsl:if>
</xsl:template>

<xsl:template match="crossref/journal/journal_issue/journal_volume" >
	<dim:field element="bibliographicCitation" qualifier="volume" mdschema="dc">
		<xsl:value-of select="volume" />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>

<xsl:template match="crossref/journal/journal_issue/issue" >
	<dim:field element="bibliographicCitation" qualifier="issue" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>

<xsl:template match="crossref/journal/journal_article/pages" >
	<xsl:choose>
		<xsl:when test="starts-with(first_page, 'e')">
		<dim:field element="bibliographicCitation" qualifier="articlenumber" mdschema="dc">
                                <xsl:value-of select="first_page" />

                        </dim:field>
		</xsl:when>
		<xsl:otherwise>
	<dim:field element="bibliographicCitation" qualifier="firstPage" mdschema="dc">
		<xsl:value-of select="first_page" />
	</dim:field>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="newline" />
	<dim:field element="bibliographicCitation" qualifier="lastPage" mdschema="dc">
		<xsl:value-of select="last_page" />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>


<xsl:template match="crossref/journal/journal_metadata">
	<dim:field element="relation" qualifier="ispartofseries" mdschema="dc">
		<xsl:value-of select="full_title" />
	</dim:field>
	<xsl:call-template name="newline" />
	<xsl:if test="./@language">
	  <dim:field element="language" qualifier="iso" mdschema="dc">
                <xsl:value-of select="./@language" />
	  </dim:field>
	  <xsl:call-template name="newline" />
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match ="crf:crossref/crf:journal/crf:journal_article/crf:doi_data/crf:doi">
	<dim:field element="identifier" qualifier="doi" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
	
</xsl:template>

<xsl:template match ="crf:crossref/crf:journal/crf:journal_article/crf:doi_data/crf:timestamp">
    <!-- do nothing -->
</xsl:template>

<xsl:template match ="crf:crossref/crf:journal/crf:journal_article/crf:doi_data/crf:resource">
    <!-- do nothing -->
</xsl:template>

<xsl:template match ="crf:crossref/crf:journal/crf:journal_article/crf:doi_data/crf:collection/*">
    <!-- do nothing -->
</xsl:template>

<xsl:template match ="crf:crossref/crf:journal/crf:journal_article/crf:titles">
<xsl:for-each select=".">
  <xsl:choose>
    <xsl:when test="position() = 1">
	<dim:field element="title" mdschema="dc">
		<xsl:value-of select="crf:title" />
	</dim:field>
	<xsl:call-template name="newline" />
     </xsl:when>
     <xsl:otherwise>
        <dim:field element="title" mdschema="dc">
                <xsl:value-of select="crf:title" />
        </dim:field>
        <xsl:call-template name="newline" />
     </xsl:otherwise>
   </xsl:choose>
</xsl:for-each>
</xsl:template>	


<xsl:template match="crf:issn[@media_type='electronic']" >
	<dim:field element="identifier" qualifier="issn" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>

<xsl:template match="crf:issn[@media_type='print']" >
	<dim:field element="identifier" qualifier="issn" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>




<xsl:template match="crf:crossref/crf:journal/crf:journal_article/crf:publication_date" >
  <xsl:if test="@media_type='online'" >
	<dim:field element="date" qualifier="issued" mdschema="dc">
		<xsl:value-of select ="crf:year" />
	</dim:field>
	<xsl:call-template name="newline" />
  </xsl:if>
  <xsl:if test="@media_type='print'" >
	<!-- do nothing -->
  </xsl:if>
</xsl:template>

<xsl:template match="crf:crossref/crf:journal/crf:journal_issue/crf:publication_date" >
  	<!-- do nothing -->
</xsl:template>


<xsl:template match="crf:crossref/crf:journal/crf:journal_article/crf:publisher_item" >
	<!-- do nothing -->
</xsl:template>

<xsl:template match="crf:crossref/crf:journal/crf:journal_article/crf:contributors/crf:person_name">
    <xsl:for-each select=".">
	  <xsl:choose>
	    <xsl:when test="@contributor_role='author'">
		<dim:field element="contributor" qualifier="author"  mdschema="dc">
			<xsl:value-of select="concat(crf:surname, ', ', crf:given_name)" />

		</dim:field>
	<xsl:call-template name="newline" />
	    </xsl:when>
	    <xsl:otherwise>
		<dim:field element="contributor" qualifier="editor"  mdschema="dc">
		    	<xsl:value-of select="concat(crf:surname, ', ', crf:given_name)" />
		</dim:field>
	<xsl:call-template name="newline" />		
	    </xsl:otherwise>
	  </xsl:choose>
    </xsl:for-each>
</xsl:template>

<xsl:template name="article_citation1">
      <xsl:if test="crf:crossref/crf:journal/crf:journal_article/crf:contributors/crf:person_name">
	<dim:field element ="identifier" qualifier="citation" mdschema="dc">

	    <xsl:for-each select="crf:crossref/crf:journal/crf:journal_article/crf:contributors/crf:person_name" >
		<xsl:value-of select="concat(crf:surname, ', ', crf:given_name)" />
		<xsl:if test="position() != last()">
		  <xsl:text>; </xsl:text>
		</xsl:if>
	      </xsl:for-each>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="crf:crossref/crf:journal/crf:journal_article/crf:publication_date/crf:year" />
		<xsl:text>): </xsl:text>
		<xsl:value-of select="crf:crossref/crf:journal/crf:journal_article/crf:titles/crf:title" />
		<xsl:text> - </xsl:text>
		<xsl:value-of select="crf:crossref/crf:journal/crf:journal_metadata/crf:full_title" />
		<xsl:text>, Vol. </xsl:text>
		<xsl:value-of select="crf:crossref/crf:journal/crf:journal_issue/crf:journal_volume/crf:volume" />
		<xsl:text>, Nr. </xsl:text>
		<xsl:value-of select="crf:crossref/crf:journal/crf:journal_issue/crf:issue" />
		<xsl:text>, p. </xsl:text>
		<xsl:value-of select="crf:crossref/crf:journal/crf:journal_article/crf:pages/crf:first_page" />
		<xsl:text>-</xsl:text>
		<xsl:value-of select="crf:crossref/crf:journal/crf:journal_article/crf:pages/crf:last_page" />
	</dim:field>
	<xsl:call-template name="newline" />
      </xsl:if>
</xsl:template>

<xsl:template match="crf:crossref/crf:journal/crf:journal_issue/crf:journal_volume" >
<!--	<dim:field element="bibliographicCitation" qualifier="volume" mdschema="dc">
		<xsl:value-of select="crf:volume" />
	</dim:field>
	<xsl:call-template name="newline" /> -->
</xsl:template>

<xsl:template match="crf:crossref/crf:journal/crf:journal_issue/crf:issue" >
<!--	<dim:field element="bibliographicCitation" qualifier="issue" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" /> -->
</xsl:template>

<xsl:template match="crf:crossref/crf:journal/crf:journal_article/crf:pages" >
<!--	<xsl:choose>
		<xsl:when test="starts-with(crf:firstPage, 'e')">
			<dim:field element="bibliographicCitation" qualifier="articlenumber" mdschema="dc">
                <xsl:value-of select="crf:first_page" />
		
        </dim:field>
		</xsl:when>
		<xsl:otherwise>

	<dim:field element="bibliographicCitation" qualifier="firstPage" mdschema="dc">
		<xsl:value-of select="crf:first_page" />
	</dim:field>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="newline" />
	<dim:field element="bibliographicCitation" qualifier="lastPage" mdschema="dc">
		<xsl:value-of select="crf:last_page" />
	</dim:field>
	<xsl:call-template name="newline" /> -->
</xsl:template>


<xsl:template match="crf:crossref/crf:journal/crf:journal_metadata">
	<dim:field element="relation" qualifier="ispartofseries" mdschema="dc">
		<xsl:value-of select="crf:full_title" />
	</dim:field>
	<xsl:call-template name="newline" />
		<xsl:if test="./@language">
          <dim:field element="language" qualifier="iso" mdschema="dc">
                <xsl:value-of select="./@language" />
          </dim:field>
          <xsl:call-template name="newline" />
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<!-- templates for book type -->

					  
<xsl:template match ="crf:crossref/crf:book/crf:book_metadata/crf:doi_data/crf:doi">
	<xsl:choose>
		<xsl:when test="//crf:crossref/crf:book/crf:book_metadata/crf:contributors/crf:person_name/@contributor_role='editor'">
			<dim:field element="type" mdschema="dc">
		                <xsl:text>anthology</xsl:text>
		        </dim:field>
		</xsl:when>
		<xsl:otherwise>	
			<dim:field element="type" mdschema="dc">
                                <xsl:text>monograph</xsl:text>
                        </dim:field>
		</xsl:otherwise>
	</xsl:choose>
	<dim:field element="identifier" qualifier="doi" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
	
</xsl:template>

<xsl:template match ="crf:crossref/crf:book/crf:book_metadata/crf:doi_data/crf:resource">
	<!-- do nothing -->
</xsl:template>

<xsl:template match ="crf:crossref/crf:book/crf:book_metadata/crf:doi_data/crf:collection">
	<!-- do nothing -->
</xsl:template>

<xsl:template match ="crf:crossref/crf:book/crf:book_metadata/crf:titles">
<xsl:for-each select=".">
  <dim:field element="title">
  <xsl:if test="position() &lt; 1">
    <xsl:attribute name="qualifier">alternative</xsl:attribute>
  </xsl:if>
  <xsl:attribute name="mdschema">dc</xsl:attribute>
		<xsl:value-of select="crf:title" />   
   </dim:field>
        <xsl:call-template name="newline" />
</xsl:for-each>
</xsl:template>	


<xsl:template match="crf:crossref/crf:book/crf:book_metadata/crf:isbn[@media_type='electronic']" >
	<dim:field element="identifier" qualifier="isbn" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>

<xsl:template match="crf:crossref/crf:book/crf:book_metadata/crf:isbn[@media_type='print']" >
	<dim:field element="identifier" qualifier="isbn" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>




<xsl:template match="crf:crossref/crf:book/crf:book_metadata/crf:publication_date" >
 <xsl:choose>
  <xsl:when test="@media_type='online'" >
	<dim:field element="date" qualifier="issued" mdschema="dc">
		<xsl:value-of select ="crf:year" />
	</dim:field>
	<xsl:call-template name="newline" />
  </xsl:when>
  <xsl:otherwise>
		<dim:field element="date" qualifier="issued" mdschema="dc">
		<xsl:value-of select ="crf:year" />
	</dim:field>
	<xsl:call-template name="newline" />
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="crf:crossref/crf:book/crf:book_metadata/crf:contributors/crf:person_name">

	  <xsl:choose>
	    <xsl:when test="@contributor_role='author'">
		<dim:field element = "contributor" qualifier="author"  mdschema="dc">
			<xsl:value-of select="concat(crf:surname, ', ', crf:given_name)" />

		</dim:field>
	<xsl:call-template name="newline" />
	    </xsl:when>
	    <xsl:otherwise>
		<dim:field element = "contributor" qualifier="editor"  mdschema="dc">
		    	<xsl:value-of select="concat(crf:surname, ', ', crf:given_name)" />
		</dim:field>
	<xsl:call-template name="newline" />		
	    </xsl:otherwise>
	  </xsl:choose>

</xsl:template>

<xsl:template name="book_citation0">
    <xsl:if test="crf:crossref/crf:book/crf:book_metadata/crf:contributors/crf:person_name">
	<dim:field element ="identifier" qualifier="citation" mdschema="dc">
	  <xsl:if test="//@book_type='other'">
	    <xsl:for-each select="crf:crossref/crf:book/crf:book_metadata/crf:contributors/crf:person_name" >
		<xsl:value-of select="concat(crf:surname, ', ', crf:given_name)" />
		<xsl:if test="position() != last()">
		  <xsl:text>; </xsl:text>
		</xsl:if>
	      </xsl:for-each>
		<xsl:text> (Ed.) (</xsl:text>
		<xsl:value-of select="crf:crossref/crf:book/crf:book_metadata/crf:publication_date/crf:year" />
		<xsl:text>): </xsl:text>
		<xsl:value-of select="crf:crossref/crf:book/crf:book_metadata/crf:titles/crf:title" />
		<xsl:text> - </xsl:text>
		<xsl:value-of select="crf:crossref/crf:book/crf:book_metadata/crf:publisher/crf:publisher_name" />
		<xsl:text>, </xsl:text>
		<xsl:value-of select="crf:crossref/crf:book/crf:book_metadata/crf:publisher/crf:publisher_place" />
	  </xsl:if>
	 </dim:field>
	<xsl:call-template name="newline" />
      </xsl:if>
</xsl:template>

<xsl:template match="crf:crossref/crf:book/crf:book_metadata/crf:publisher/crf:publisher_name" >
<!--	<dim:field element="publisher" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" /> -->
</xsl:template>

<xsl:template match="crf:crossref/crf:book/crf:book_metadata/crf:publisher/crf:publisher_place" >
<!--	<dim:field element="publisher" qualifier="place" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" /> -->
</xsl:template>

<xsl:template match="crf:crossref/crf:book/crf:book_metadata">
      <xsl:if test="./@language">
	<dim:field element="language" qualifier="iso" mdschema="dc">
		<xsl:value-of select="@language" />
	</dim:field>
	<xsl:call-template name="newline" />
      </xsl:if>
        <xsl:apply-templates/>
</xsl:template>

<xsl:template match ="crossref/book/book_metadata/doi_data/doi">
	<dim:field element="identifier" qualifier="doi" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
	
</xsl:template>

<xsl:template match ="crossref/book/book_metadata/doi_data/resource">
    <!-- do nothing -->
</xsl:template>

<xsl:template match ="crossref/book/book_metadata/doi_data/collection">
    <!-- do nothing -->
</xsl:template>

<xsl:template match ="crossref/book/book_metadata/titles">
 <xsl:for-each select=".">
  <dim:field element="title">
  <xsl:if test="position() &lt; 1">
    <xsl:attribute name="qualifier">alternative</xsl:attribute>
  </xsl:if>
  <xsl:attribute name="mdschema">dc</xsl:attribute>
		<xsl:value-of select="title" />   
   </dim:field>
        <xsl:call-template name="newline" />
 </xsl:for-each>
</xsl:template>	


<xsl:template match="crossref/book/book_metadata/isbn[@media_type='electronic']" >
	<dim:field element="identifier" qualifier="isbn" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>

<xsl:template match="crossref/book/book_metadata/isbn[@media_type='print']" >
	<dim:field element="identifier" qualifier="isbn" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" />
</xsl:template>




<xsl:template match="crossref/book/book_metadata/publication_date" >
 <xsl:choose>
  <xsl:when test="@media_type='online'" >
	<dim:field element="date" qualifier="issued" mdschema="dc">
		<xsl:value-of select ="year" />
	</dim:field>
	<xsl:call-template name="newline" />
  </xsl:when>
  <xsl:otherwise>
		<dim:field element="date" qualifier="issued" mdschema="dc">
		<xsl:value-of select ="year" />
	</dim:field>
	<xsl:call-template name="newline" />
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="crossref/book/book_metadata/contributors/person_name">

	  <xsl:choose>
	    <xsl:when test="@contributor_role='author'">
		<dim:field element = "contributor" qualifier="author"  mdschema="dc">
			<xsl:value-of select="concat(surname, ', ', given_name)" />

		</dim:field>
	<xsl:call-template name="newline" />
	    </xsl:when>
	    <xsl:otherwise>
		<dim:field element = "contributor" qualifier="editor"  mdschema="dc">
		    	<xsl:value-of select="concat(surname, ', ', given_name)" />
		</dim:field>
	<xsl:call-template name="newline" />		
	    </xsl:otherwise>
	  </xsl:choose>

</xsl:template>

<xsl:template name="book_citation1">
    <xsl:if test="crossref/book/book_metadata/contributors/person_name">
	<dim:field element ="identifier" qualifier="citation" mdschema="dc">
	  <xsl:if test="//@book_type='other'">
	    <xsl:for-each select="crossref/book/book_metadata/contributors/person_name" >
		<xsl:value-of select="concat(surname, ', ', given_name)" />
		<xsl:if test="position() != last()">
		  <xsl:text>; </xsl:text>
		</xsl:if>
	      </xsl:for-each>
		<xsl:text> (Ed.) (</xsl:text>
		<xsl:value-of select="crossref/book/book_metadata/publication_date/year" />
		<xsl:text>): </xsl:text>
		<xsl:value-of select="crossref/book/book_metadata/titles/title" />
		<xsl:text> - </xsl:text>
		<xsl:value-of select="crossref/book/book_metadata/publisher/publisher_name" />
		<xsl:text>, </xsl:text>
		<xsl:value-of select="crossref/book/book_metadata/publisher/publisher_place" />
	  </xsl:if>
	 </dim:field>
	<xsl:call-template name="newline" />
     </xsl:if>
</xsl:template>

<xsl:template match="crossref/book/book_metadata/publisher/publisher_name" >
<!--	<dim:field element="publisher" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" /> -->
</xsl:template>

<xsl:template match="crossref/book/book_metadata/publisher/publisher_place" >
<!--	<dim:field element="publisher" qualifier="place" mdschema="dc">
		<xsl:value-of select="." />
	</dim:field>
	<xsl:call-template name="newline" /> -->
</xsl:template>

<xsl:template match="crossref/book/book_metadata">
    <xsl:if test="./@language">
	<dim:field element="language" qualifier="iso" mdschema="dc">
		<xsl:value-of select="@language" />
	</dim:field>
	<xsl:call-template name="newline" />
    </xsl:if>
        <xsl:apply-templates/>
</xsl:template>

<xsl:template name="newline">
  <xsl:text>
  </xsl:text>
</xsl:template>

</xsl:stylesheet>

