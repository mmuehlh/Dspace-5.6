<?xml version="1.0"?>
<xsl:stylesheet
	xmlns:srw="http://www.loc.gov/zing/srw/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:diag="http://www.loc.gov/zing/srw/diagnostic/"
	xmlns:xcql="http://www.loc.gov/zing/cql/xcql/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:pica="info:srw/schema/5/picaXML-v1.0"
	version="1.0"
        exclude-result-prefixes="srw dc diag xcql pica xsi">

<xsl:output indent="yes" encoding="UTF-8" method="xml" />                  

<xsl:template match="*"/>
<xsl:strip-space elements="*" />

	

<xsl:template match="/srw:searchRetrieveResponse">
	
    <xsl:apply-templates select="srw:records/srw:record"/>
</xsl:template>


<xsl:template match="srw:records/srw:record">
     <xsl:apply-templates select="srw:recordData/pica:record"/>
  </xsl:template>



<xsl:template match="srw:recordData/pica:record">
  <dim:dim>
    <xsl:call-template name="linebreak" />  
    <xsl:apply-templates />
<!--     <xsl:call-template name="freeKeywords" />
     <xsl:call-template name="bibliographicCitation" /> -->
    </dim:dim>
</xsl:template>


  <!-- pica 003, 004: identifier -->
  <xsl:template match="pica:datafield[@tag='003@']">
        <dim:field element="identifier" qualifier="ppn">
                <xsl:value-of select="pica:subfield[@code='0']" />
        </dim:field>
                <xsl:call-template name="linebreak" />  
    </xsl:template>

   <xsl:template match="pica:datafield[@tag='004U']">
        <dim:field element="identifier" qualifier="urn">
                <xsl:value-of select="pica:subfield[@code='0']" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />  
   </xsl:template>

     <xsl:template match="pica:datafield[@tag='004P']">
	
	<xsl:choose>
	<xsl:when test="pica:subfield[@code='S'] = 'p'">
         <dim:field element="identifier" qualifier="pISBN">
                <xsl:value-of select="pica:subfield[@code='A']" />
                
        </dim:field>
	</xsl:when>
	<xsl:when test="pica:subfield[@code='S'] = 'e'">
         <dim:field element="identifier" qualifier="eISBN">
                <xsl:value-of select="pica:subfield[@code='A']" />
                
        </dim:field>
	</xsl:when>
	<xsl:otherwise>
         <dim:field element="identifier" qualifier="isbn">
                <xsl:value-of select="pica:subfield[@code='A']" />
                
        </dim:field>		
	</xsl:otherwise>
	</xsl:choose>

                <xsl:call-template name="linebreak" />  
   </xsl:template>

   <xsl:template match="pica:datafield[@tag='004V']">
        <dim:field element="identifier" qualifier="doi">
                <xsl:value-of select="pica:subfield[@code='0']" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />  
   </xsl:template>

  <!-- 010@: language -->
    <xsl:template match="pica:datafield[@tag='010@']">

        <dim:field element="language" qualifier="iso">
                <xsl:value-of select="pica:subfield[@code='a']" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />  
   </xsl:template>

  <!-- 011@: date.issued -->

   <xsl:template match="pica:datafield[@tag='011@']">
        <dim:field element="date" qualifier="issued">
                <xsl:value-of select="pica:subfield[@code='a']" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />  
   </xsl:template>

  <!-- 021A:title -->

  <xsl:template match="pica:datafield[@tag='021A']">
        <dim:field element="title">
                <xsl:value-of select="translate(pica:subfield[@code='a'], '@', '')" />
        </dim:field>
                <xsl:call-template name="linebreak" />  
	<xsl:if test="pica:subfield[@code='f']">
		<dim:field element="title" qualifier="translated">
                 	<xsl:value-of select="translate(pica:subfield[@code='f'], '@', '')" />
	         </dim:field>
		<xsl:call-template name="linebreak" />
	</xsl:if>
        <xsl:if test="pica:subfield[@code='d']">
          <dim:field element="title" qualifier="alternative">
                <xsl:value-of select="translate(pica:subfield[@code='d'], '@', '')" />
         </dim:field>
                <xsl:call-template name="linebreak" />  
        </xsl:if>
   </xsl:template>
 <!-- 028X: Autoren [a: Nachname, d: Vorname; 028A erster Autor, weitere 028B wiederholbar]-->

  <xsl:template match="pica:datafield[@tag='028A']">

        <dim:field element="contributor" qualifier="author">
                <xsl:value-of select="pica:subfield[@code='a']" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="pica:subfield[@code='d']" />
        </dim:field>
                <xsl:call-template name="linebreak" />  
   </xsl:template>

   <xsl:template match="pica:datafield[@tag='028B']">
	<xsl:for-each select=".">
        <dim:field element="contributor" qualifier="author">
                <xsl:value-of select="pica:subfield[@code='a']" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="pica:subfield[@code='d']" />
        </dim:field>
                <xsl:call-template name="linebreak" />  
	</xsl:for-each>
   </xsl:template>

   <!-- 028C: Editoren, gefeierte Person uws. nicht unterscheidbar [a: Nachname, d: Vorname]-->

  <xsl:template match="pica:datafield[@tag='028C']">

        <dim:field element="contributor" qualifier="editor">
                <xsl:value-of select="pica:subfield[@code='a']" />
                <xsl:text>, </xsl:text>
                <xsl:value-of select="pica:subfield[@code='d']" />
        </dim:field>
                <xsl:call-template name="linebreak" />  
   </xsl:template>

      <!-- 033A: vom Doktyp abhängig - Bücher (Oau): Verlagsdaten [pica:subfields p: Verlagsort, n: Verleger], Artikel(Osu): bibl.Angaben zur Zeitschrift [subfields[d: Band, e: Heftnr, h: Seiten, j: Jahr]-->
   <xsl:template match="pica:datafield[@tag='033A']">

          
           
                <dim:field element="publisher">
                  <xsl:value-of select="pica:subfield[@code='n']" />
		  <xsl:if test="pica:subfield[@code='p']">
			<xsl:text>, </xsl:text><xsl:value-of select="pica:subfield[@code='p']" />
		  </xsl:if>
                </dim:field>
                <xsl:call-template name="linebreak" />  
                
                

   </xsl:template>

   <!-- 034D: Format und Umfang -->
   <xsl:template match="pica:datafield[@tag='034D']">

          <xsl:variable name="pure"><xsl:value-of select="pica:subfield[@code='a']" /></xsl:variable>
                <xsl:if test="contains($pure, '(')">
                  <xsl:variable name="fvalue"><xsl:value-of select="substring-after($pure, '(')" /></xsl:variable>
                <dim:field element="format" qualifier="extent">
                  <xsl:value-of select="translate($fvalue, '()', '')" />
                </dim:field>
                <xsl:call-template name="linebreak" />  
                </xsl:if>
                

   </xsl:template>
  
  <!-- 037C:Hochschule bei Diss. --> 
   <xsl:template match="pica:datafield[@tag='037C']">

          
           
                <dim:field element="publisher">
                  <xsl:value-of select="substring-before(pica:subfield[@code='a'], ', Diss')" />
		  <xsl:if test="pica:subfield[@code='b']">
			<xsl:text> </xsl:text><xsl:value-of select="translate(pica:subfield[@code='b'], '@', '')" />
		  </xsl:if>
                </dim:field>
                <xsl:call-template name="linebreak" />  
                
                

   </xsl:template>
   <!-- BibliographicCitation: aggregate several fields -->
   
   <!-- 39B: Angaben zur Zeitschrift [a: Zeitschriftenname, 0: ISSN, n: Verlag, p: Erscheinungsort] -->

  <xsl:template name="bibliographicCitation">
	<xsl:choose>
	<!-- Falls Zeitschrift-->
	<xsl:when test="pica:datafield[@tag='039B']">
	      
	 <dim:field element="identifier" qualifier="citation">
                <xsl:value-of select="pica:datafield[@tag='039B']/pica:subfield[@code='a']" /><xsl:text>; </xsl:text>
		<xsl:if test="pica:datafield[@tag='031A']">
			
			<xsl:if test="pica:datafield[@tag='031A']/pica:subfield[@code='d']">
				<xsl:text>Vol. </xsl:text><xsl:value-of select="pica:datafield[@tag='031A']/pica:subfield[@code='d']" /><xsl:text>.</xsl:text>
			</xsl:if>
			<xsl:if test="pica:datafield[@tag='031A']/pica:subfield[@code='j']">
				<xsl:value-of select="pica:datafield[@tag='031A']/pica:subfield[@code='j']" /><xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="pica:datafield[@tag='031A']/pica:subfield[@code='e']">
				<xsl:text>No. </xsl:text><xsl:value-of select="pica:datafield[@tag='031A']/pica:subfield[@code='e']" /><xsl:text>, </xsl:text>
			</xsl:if>
			<xsl:if test="pica:datafield[@tag='031A']/pica:subfield[@code='h']">
				<xsl:text>p. </xsl:text><xsl:value-of select="pica:datafield[@tag='031A']/pica:subfield[@code='h']" />
			</xsl:if>
		</xsl:if>
	  </dim:field>
	</xsl:when>
	<!-- Falls Sammelbandbeitrag -->
	<xsl:when test="pica:datafield[@tag='046R']">
		<dim:field element="identifier" qualifier="citation">
                <xsl:value-of select="pica:datafield[@tag='046R']/pica:subfield[@code='a']" />
		</dim:field>
	</xsl:when>
	
	<!-- Falls Kongressbeitrag: 030F, a: Kongresstitel, j: Zählung, k: Ort, p: Zeit -->
	<xsl:when test="pica:datafield[@tag='030F']">
		<dim:field element="identifier" qualifier="citation">
                <xsl:value-of select="pica:datafield[@tag='030F']/pica:subfield[@code='a']" /><xsl:text> </xsl:text>
		<xsl:if test="pica:datafield[@tag='030F']/pica:subfield[@code='j']">
			<xsl:value-of select="pica:datafield[@tag='030F']/pica:subfield[@code='j']" />
		</xsl:if>
		<xsl:if test="pica:datafield[@tag='030F']/pica:subfield[@code='p']">
			<xsl:text> - </xsl:text><xsl:value-of select="pica:datafield[@tag='030F']/pica:subfield[@code='p']" />
		</xsl:if>
		<xsl:if test="pica:datafield[@tag='030F']/pica:subfield[@code='k']">
			<xsl:text>, </xsl:text><xsl:value-of select="pica:datafield[@tag='030F']/pica:subfield[@code='k']" />
		</xsl:if>
		<xsl:text>; </xsl:text><xsl:value-of select="pica:datafield[@tag='011@']/pica:subfield[@code='a']" />		</dim:field>
	</xsl:when>	
             
	</xsl:choose>
                <xsl:call-template name="linebreak" />  

   </xsl:template> 

   <!-- 044K, 045G, 045F, 045H, 145Z: Schlagwörter, Klassifikationen -->

     <xsl:template name="freeKeywords">
	<xsl:if test="pica:datafield[@tag='044K']">
        <dim:field element="subject" qualifier="free">
		<xsl:for-each select="pica:datafield[@tag='044K']">
                <xsl:value-of select="pica:subfield[@code='a']" />
		<xsl:if test="position() != last()">
			<xsl:text>; </xsl:text>
		</xsl:if>
                </xsl:for-each>
        </dim:field>
                <xsl:call-template name="linebreak" /> 
	</xsl:if> 
   </xsl:template>

     <xsl:template match="pica:datafield[@tag='039B']">
        <dim:field element="publisher">
	
                <xsl:value-of select="pica:subfield[@code='n']" /> <xsl:value-of select="concat(', ', subfield[@code='p'])" />

        </dim:field>
                <xsl:call-template name="linebreak" />  
        <dim:field element="relation" qualifier="issn">
	
                <xsl:value-of select="pica:subfield[@code='0']" /> 
        </dim:field>
                <xsl:call-template name="linebreak" /> 
   </xsl:template>

     <xsl:template match="pica:datafield[@tag='045H']">
        <dim:field element="subject" qualifier="ddc">
		<xsl:for-each select=".">
                <xsl:value-of select="pica:subfield[@code='a']" />
                </xsl:for-each>
        </dim:field>
                <xsl:call-template name="linebreak" />  
   </xsl:template>

   <xsl:template match="pica:datafield[@tag='045M']">
	<xsl:for-each select=".">
        <dim:field element="subject" qualifier="gok">
                <xsl:value-of select="pica:subfield[@code='a']" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />  
	</xsl:for-each>
   </xsl:template>

   <xsl:template match="pica:datafield[@tag='045Q']">
	<xsl:for-each select=".">
        <dim:field element="subject" qualifier="bk">
                <xsl:value-of select="pica:subfield[@code='a']" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />  
	</xsl:for-each>
   </xsl:template>

   <xsl:template match="pica:datafield[@tag='145Z']">
      <xsl:for-each select=".">
        <xsl:for-each select="pica:subfield[@code='a']">
        <xsl:choose>
        <xsl:when test="(position() mod 2) = 1" >
        <dim:field element="subject" qualifier="gok">
                <xsl:value-of select="normalize-space(.)" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />
        </xsl:when>
        <xsl:otherwise>
        <dim:field element="subject" qualifier="gokverbal">
                <xsl:value-of select="normalize-space(.)" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />   
        </xsl:otherwise>
        </xsl:choose>
          </xsl:for-each>
                
      </xsl:for-each>
   </xsl:template>


    <!-- 046I: abstract -->
    <xsl:template match="pica:datafield[@tag='047I']">
        <dim:field element="description" qualifier="abstract">
                <xsl:value-of select="pica:subfield[@code='a']" />
                
        </dim:field>
                <xsl:call-template name="linebreak" />  
   </xsl:template>




 

    <xsl:template name="static">
        <dim:field element="type">
                <xsl:text>book</xsl:text>
                
        </dim:field>
        
        <xsl:call-template name="linebreak" />
        <dim:field element="rights" qualifier="uri">
                <xsl:text>http://repository.geo-leo.de/rights</xsl:text>
                
        </dim:field>
        
   </xsl:template>

   

    

  <xsl:template name="linebreak">
    <xsl:text>
    </xsl:text>
  </xsl:template>


<xsl:template name="format">
    <dim:field element="format" qualifier="mimetype">
	<xsl:text>application/pdf</xsl:text>
    </dim:field>
</xsl:template>

</xsl:stylesheet>

