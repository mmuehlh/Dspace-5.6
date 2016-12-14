package org.dspace.submit.step;


import org.dspace.content.InProgressSubmission;
import org.dspace.submit.AbstractProcessingStep;
import org.dspace.submit.step.SampleStep;
import org.dspace.core.Context;
import org.dspace.core.PluginManager;
import org.dspace.app.util.SubmissionInfo;
import org.dspace.app.util.Util;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.Metadatum;
import org.dspace.content.crosswalk.IngestionCrosswalk;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.http.HttpException;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.CoreConnectionPNames;
import org.jdom.Element;
import java.net.URL;
import org.jdom.input.DOMBuilder;
import org.jdom.output.XMLOutputter;
import org.jdom.output.Format;
import org.jdom.xpath.XPath;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import org.apache.xerces.parsers.DOMParser;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import java.io.*;
import java.sql.SQLException;
import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;
import org.dspace.core.ConfigurationManager;

/**
 * Main processing code for lookups
 * based on Code from https://wiki.duraspace.org/display/DSPACE/PopulateMetadataFromPubMed
 */

public class PrefillStep extends AbstractProcessingStep
{
    /** log4j logger */
    private static Logger log = Logger.getLogger(PrefillStep.class);

    public int doProcessing(Context context, HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, SubmissionInfo submissionInfo) throws ServletException, IOException, SQLException, AuthorizeException
    {
        String identifier = "";
        String originalId = "";
        String type = "";
        if ( httpServletRequest.getParameter("identifier_pmid").length() > 1)
        {
            identifier = httpServletRequest.getParameter("identifier_pmid");
            originalId = httpServletRequest.getParameter("original_pmid");
            type = "pubmed";
        }
            else if (httpServletRequest.getParameter("identifier_doi").length() > 1)
        {
            identifier = httpServletRequest.getParameter("identifier_doi");
            originalId = httpServletRequest.getParameter("original_doi");
            type = "doi";
        }
        /*else if ( httpServletRequest.getParameter("identifier_fsid").length() > 1)
        {
            identifier = httpServletRequest.getParameter("identifier_fsid");
            originalId = httpServletRequest.getParameter("original_fsid");
            type = "fs";
        }*/

        else if ( httpServletRequest.getParameter("identifier_ppn").length() > 1)
        {
            identifier = httpServletRequest.getParameter("identifier_ppn");
            originalId = httpServletRequest.getParameter("original_ppn");
            type = "ppn";
         }
         log.debug("DEBUG: identifier: " + type);

         
          boolean forceLookup = Util.getBoolParameter(httpServletRequest, "force_refresh");

            // If we have an identifier, and it:
            // - is not the same as when the form was build (ie. it is a first time entry, or has been changed)
            // - the lookup has been forced
            // then fill the metadata with the new values
            if (!StringUtils.isEmpty(identifier))
            {
                if (!isValidID(identifier, type))
                {

                    httpServletRequest.setAttribute("identifier.error", true);
                    return SampleStep.STATUS_USER_INPUT_ERROR;
                }


                log.info("INFO: identifier valid");

                //Fetch data if no data existent or force lookup only
                if (!identifier.equals(originalId) ) {
                        if (forceLookup)
                        {
                            // Clear data only if the search param is valid
                            clearMetaDataValues(submissionInfo);
                        }

                        if (!fetchData(context, submissionInfo, identifier, type)) {
                            // the Fetch failed..display the inability to get details..and allow user to enter
                            // details manually
                            httpServletRequest.setAttribute("identifier.error", Boolean.valueOf(true));

                            return SampleStep.STATUS_USER_INPUT_ERROR;
                        }
                }

            }

            return SampleStep.STATUS_COMPLETE;
        }

        public int getNumberOfPages(HttpServletRequest httpServletRequest, SubmissionInfo submissionInfo) throws ServletException
        {
            return 1;
        }

        protected boolean isValidID(String id, String type) {

            if (type.equals("pubmed")) {
                try {
                    // A valid PMID will be parseable as an integer
                    return (Integer.parseInt(id, 10) > 0);
                } catch (NumberFormatException nfe) {
                    return false;
                }
            } else if (type.equals("doi")) {
                try {
                    // A valid DOI starts with 10, then "." then
                    return (id.startsWith("10."));
                } catch (NumberFormatException nfe) {
                    return false;
                }
            } else if (type.equals("fs")) {
                try {
                    // A valid FSID will be parseable as an integer
                    return (Integer.parseInt(id) > 0);
                } catch (NumberFormatException nfe) {
                    return false;
                }

            } else if (type.equals("ppn"))
            //A valid PPN consists of 9 digits
            {
                return (id.length() == 9);

            } else
                return false;


        }

        protected Element retrievePubmedXML(String pmid) throws Exception
        {
            HttpGet method = null;
            try
            {
                HttpClient client = new DefaultHttpClient();


                try {
                    URIBuilder uriBuilder = new URIBuilder(ConfigurationManager.getProperty("pubmed.url"));
                    uriBuilder.addParameter("db", "pubmed");
                    uriBuilder.addParameter("retmode", "xml");
                    uriBuilder.addParameter("id", pmid);
                    method = new HttpGet(uriBuilder.build());
                } catch (Exception ex)
                {
                    throw new Exception("Pubmed Query Error: "+ex.getMessage());
                }

                // Execute the method.
                HttpResponse response = client.execute(method);
                StatusLine statusLine = response.getStatusLine();
                int statusCode = statusLine.getStatusCode();

                if (statusCode != HttpStatus.SC_OK)
                {
                    throw new RuntimeException("WS call failed: " + statusLine);
                }

                DocumentBuilderFactory factory = DocumentBuilderFactory
                        .newInstance();
                factory.setValidating(false);
                factory.setIgnoringComments(true);
                factory.setIgnoringElementContentWhitespace(true);

                DocumentBuilder builder = factory.newDocumentBuilder();
                Document doc = builder
                        .parse(response.getEntity().getContent());


                if(doc != null)
                {

                    org.w3c.dom.Element element = doc.getDocumentElement();

                    DOMBuilder docbuilder = new DOMBuilder();

                    log.info("Pubmed-Data: " + docbuilder.build(element).toString());

                    return docbuilder.build(element);
                }
            }
            finally
            {
                if (method != null)
                {
                    method.releaseConnection();
                }
            }
            return null;
        }


        protected Element retrieveDOIXML(String doi) throws Exception
        {
        Document doc = null;
            try
            {
                DOMParser parser = new DOMParser();
                parser.setFeature("http://xml.org/sax/features/validation",false);
                String doiURL = ConfigurationManager.getProperty("doi.url");
                parser.parse(doiURL + doi);
                doc=parser.getDocument();


                Transformer transformer = TransformerFactory.newInstance().newTransformer();
                transformer.setOutputProperty(OutputKeys.INDENT, "yes");

                //initialize StreamResult with File object to save to file
                StreamResult result = new StreamResult(new StringWriter());
                DOMSource source = new DOMSource(doc);
                transformer.transform(source, result);

                String xmlString = result.getWriter().toString();
                log.info("Fetched Doc: " + xmlString);


                if(doc != null)
                {

                    org.w3c.dom.Element element = doc.getDocumentElement();

                    DOMBuilder builder = new DOMBuilder();

                    log.info("DOI-Data: " + builder.build(element).toString());

                    return builder.build(element);
                }

            }
            catch (Exception ex)
            {
                throw new Exception("Extracting CrossrefXML: "+ex.getMessage(),ex.getCause());
            }

            return null;
        }

        protected Element retrieveFSXML(String fsid) throws Exception
        {

        Document doc = null;
            try
            {
            DOMParser parser = new DOMParser();
            parser.setFeature("http://xml.org/sax/features/validation",false);
            parser.setFeature("http://xml.org/sax/features/namespaces",false);
            parser.setFeature("http://apache.org/xml/features/nonvalidating/load-dtd-grammar",false);
            parser.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd",false);
            parser.parse("/opt/dspace/fsdata/" + fsid + ".xml");
            doc = parser.getDocument();

                 if(doc != null)
                 {
                    // There seem to be some illegal PI in the xml doc, hence getting
                    // the root element and then convert to JDOM Element
                    org.w3c.dom.Element element = doc.getDocumentElement();
                    DOMBuilder builder = new DOMBuilder();
                    return builder.build(element);
                  }


            }
            catch (Exception ex)
            {
                throw new Exception("Extracting FSXML: "+ex.getMessage(),ex.getCause());
            }

            return null;
          }
      
        protected Element retrievePPNXML(String ppn) throws Exception
        {
            //String sruURL = ConfigurationManager.getProperty("sruURL");
            Document doc = null;
            try
            {
            log.info("Trying to fetch...");
                DOMParser parser = new DOMParser();
                parser.setFeature("http://xml.org/sax/features/validation",false);
                String gbvURL = ConfigurationManager.getProperty("gbv.url");
                log.info("Address: " + gbvURL + ppn);
                parser.parse(gbvURL + ppn);
                doc = parser.getDocument();

                          Transformer transformer = TransformerFactory.newInstance().newTransformer();
               transformer.setOutputProperty(OutputKeys.INDENT, "yes");

                    //initialize StreamResult with File object to save to file
                    StreamResult result = new StreamResult(new StringWriter());
                    DOMSource source = new DOMSource(doc);
                    transformer.transform(source, result);

                    String xmlString = result.getWriter().toString();
                    log.info("Fetched Doc: " + xmlString);

                // Check to see if document is a valid article...all article has the DTD specified
                 if(doc != null)
                 {
                    // There seem to be some illegal PI in the xml doc, hence getting
                    // the root element and then convert to JDOM Element
                    org.w3c.dom.Element element = doc.getDocumentElement();
                    DOMBuilder builder = new DOMBuilder();
                    return builder.build(element);
                  }

            }
            catch (SAXException ex)
            {
                throw new Exception("Extracting PPN: "+ex.getMessage(),ex.getCause());
            }

            return null;
        }


        protected void clearMetaDataValues(SubmissionInfo subInfo)
        {
            Item item = subInfo.getSubmissionItem().getItem();
            item.clearMetadata(Item.ANY, Item.ANY, Item.ANY, Item.ANY);

            InProgressSubmission wsi = subInfo.getSubmissionItem();
            Item collTemplate = null;

            try {
                wsi.getCollection().getTemplateItem();
                if (collTemplate != null)
                {
                    Metadatum[] md = collTemplate.getMetadata(Item.ANY, Item.ANY, Item.ANY, Item.ANY);



                    for (int n = 0; n < md.length; n++) {
                        item.addMetadata(md[n].schema, md[n].element, md[n].qualifier, md[n].language, md[n].value);

                    }
                    item.update();

                }
            }
            catch (SQLException sqle)
            {
                log.error("Unable to get collection template! "+ sqle.getMessage());
            }
            catch (AuthorizeException ae)
            {
                log.error("Could not insert default fields from collection template! "+ ae.getMessage());
            }

        }


        protected boolean fetchData(Context context, SubmissionInfo subInfo, String id, String type)
        {

         if (type.equals("pubmed"))
               return fetchPubmedData(context, subInfo, id);
             else if (type.equals("doi"))
               return fetchDOIData(context, subInfo, id);
          /*else if (type.equals("fs"))
               return fetchFSData(context, subInfo, id);*/
          else if (type.equals("ppn"))
               return fetchPPNData(context, subInfo, id);
          else return false;



        }

        protected boolean fetchPubmedData(Context context, SubmissionInfo subInfo, String pmid)
        {
            try
            {
                Element jElement = retrievePubmedXML(pmid);
                if(jElement != null)
                {
                    // Use the ingest process to parse the XML document, transformation is done
                    // using XSLT
                    IngestionCrosswalk xwalk = (IngestionCrosswalk) PluginManager.getNamedPlugin(IngestionCrosswalk.class, "PMID");
                    xwalk.ingest(context, subInfo.getSubmissionItem().getItem(), jElement);
                    return true;
                }
            }
            catch (Exception ex)
            {
                // As this is not a critical error...will not terminate the process...allow user to
                // manually enter details

                log.error("Unable to fetch pubmed data & load external data: "+ ex.getMessage(), ex.getCause());
            }
            return false;
        }


        protected boolean fetchDOIData(Context context, SubmissionInfo subInfo, String doi)
        {
        log.info("DEBUG: fetching DOIData");
            try
            {
                Element jElement = retrieveDOIXML(doi);

            log.info("DOI-Data: " + jElement.toString());

                if(jElement != null)
                {
                    // Use the ingest process to parse the XML document, transformation is done
                    // using XSLT
                    IngestionCrosswalk xwalk = (IngestionCrosswalk) PluginManager.getNamedPlugin(
                                                        IngestionCrosswalk.class, "DOI");
                    xwalk.ingest(context, subInfo.getSubmissionItem().getItem(), jElement);
                    return true;
                }
            }
            catch (Exception ex)
            {
                // As this is not a critical error...will not terminate the process...allow user to
                // manually enter details
                log.error("Unable to fetch doi data & load external data: "+ ex.getMessage(), ex.getCause());
            }
            return false;
        }


        protected boolean fetchFSData(Context context, SubmissionInfo subInfo, String fsid)
        {
            try
            {
                Element jElement = retrieveFSXML(fsid);
                if(jElement != null)
                {
                    // Use the ingest process to parse the XML document, transformation is done
                    // using XSLT
                    IngestionCrosswalk xwalk = (IngestionCrosswalk) PluginManager.getNamedPlugin(
                                                        IngestionCrosswalk.class, "FSID");
                    xwalk.ingest(context, subInfo.getSubmissionItem().getItem(), jElement);
                    return true;
                }
            }
            catch (Exception ex)
            {
                // As this is not a critical error...will not terminate the process...allow user to
                // manually enter details
                log.error("Unable to fetch fsdata & load external data: "+ ex.getMessage(), ex.getCause());
            }
            return false;
        }
    
        protected boolean fetchPPNData(Context context, SubmissionInfo subInfo, String ppn)
        {
            try
            {
                Element jElement = retrievePPNXML(ppn);
                if(jElement != null)
                {
                    // Use the ingest process to parse the XML document, transformation is done
                    // using XSLT
                    IngestionCrosswalk xwalk = (IngestionCrosswalk) PluginManager.getNamedPlugin(
                                                        IngestionCrosswalk.class, "PPN");
                    xwalk.ingest(context, subInfo.getSubmissionItem().getItem(), jElement);
                    return true;
                }
            }
            catch (Exception ex)
            {
                // As this is not a critical error...will not terminate the process...allow user to
                // manually enter details
                log.error("Unable to fetch ppndata & load external data: "+ ex.getMessage(), ex.getCause());
            }
            return false;
        }
}
