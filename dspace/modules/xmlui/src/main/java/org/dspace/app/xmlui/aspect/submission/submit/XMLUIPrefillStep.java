/*
 * XMLUIPrefillStep.java
 *
 * Version: $Revision: 3705 $
 *
 * Date: $Date: 2009-04-11 17:02:24 +0000 (Sat, 11 Apr 2009) $
 *
 * Copyright (c) 2002, Hewlett-Packard Company and Massachusetts
 * Institute of Technology.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Hewlett-Packard Company nor the name of the
 * Massachusetts Institute of Technology nor the names of their
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package org.dspace.app.xmlui.aspect.submission.submit;

import java.io.IOException;
import java.sql.SQLException;

import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.aspect.submission.AbstractSubmissionStep;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.app.xmlui.wing.element.CheckBox;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.List;
import org.dspace.app.xmlui.wing.element.Text;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.Metadatum;
import org.dspace.content.Item;
import org.xml.sax.SAXException;

/**
 * This is a new step of the item submission processes. It gives
 * the possibility to fetch automatically metadata from several ressources
 * based on appropriate IDs of an already published document.
 * 
 * Questions:
 *  - ID of the Publication
 *  
 * 
 */
public class XMLUIPrefillStep extends AbstractSubmissionStep
{
	/** Language Strings **/

    protected static final Message T_head= 
        message("xmlui.Submission.submit.PrefillStep.head");
    protected static final Message T_explanation_note= 
        message("xmlui.Submission.submit.PrefillStep.explanation_note");
    protected static final Message T_pmid= 
        message("xmlui.Submission.submit.PrefillStep.pmid");
    protected static final Message T_doi= 
        message("xmlui.Submission.submit.PrefillStep.doi");
    /*protected static final Message T_fsid=
        message("xmlui.Submission.submit.PrefillStep.fsid");*/
    protected static final Message T_pmid_label= 
        message("xmlui.Submission.submit.PrefillStep.pmlabel");  
    protected static final Message T_doi_label= 
        message("xmlui.Submission.submit.PrefillStep.doilabel");
    /*protected static final Message T_fsid_label=
        message("xmlui.Submission.submit.PrefillStep.fslabel");  */
    protected static final Message T_ppn_label= 
        message("xmlui.Submission.submit.PrefillStep.ppnlabel");
    protected static final Message T_refresh= 
        message("xmlui.Submission.submit.PrefillStep.refresh.label"); 
    protected static final Message T_identifier_error=
        message("xmlui.Submission.submit.PrefillStep.identifier.error");
    protected static final Message T_identifier_info=
        message("xmlui.Submission.submit.PrefillStep.identifier.info");

    protected static final Message T_help=
        message("xmlui.Submission.submit.PrefillStep.help");
    protected static final Message T_refresh_help=
        message("xmlui.Submission.submit.PrefillStep.refresh_help");


    /**
	 * Establish our required parameters, abstractStep will enforce these.
	 */
	public XMLUIPrefillStep()
	{
		this.requireSubmission = true;
		//this.requireStep = true;
	}

    public void addPageMeta(PageMeta pageMeta) throws SAXException,
    WingException
    {
        
        pageMeta.addMetadata("title").addContent(T_submission_title);
        pageMeta.addTrailLink(contextPath + "/",T_dspace_home);
        pageMeta.addTrail().addContent(T_submission_trail);
    }   
    
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException
    {
    	// Get any metadata that may be removed by unselecting one of these options.
	Request request = ObjectModelHelper.getRequest(objectModel);
	Boolean fresh = false;
    	Item item = submission.getItem();
		Collection collection = submission.getCollection();
		String actionURL = contextPath + "/handle/"+collection.getHandle() + "/submit/" + knot.getId() + ".continue";

		Metadatum[]  pmid = item.getDC("identifier", "pmid", Item.ANY);
		if (pmid != null) {System.out.println("PMID: " + pmid);}
		Metadatum[]  doi = item.getDC("identifier", "doi", Item.ANY);
		if (doi != null) {System.out.println("DOI: " + doi);}
		/*Metadatum[]  fsid = item.getDC("identifier", "fs", Item.ANY);
		if (fsid != null) {System.out.println("FSID: " + fsid);}*/
		Metadatum[]  ppn = item.getDC("identifier", "ppn", Item.ANY);
		if (ppn != null) {System.out.println("PPN: " + ppn);}
		

        // Generate a from asking the user the PubMedID 
        
    	Division div = body.addInteractiveDivision("prefill", actionURL, Division.METHOD_POST, "primary submission");
    	div.setHead(T_submission_head);
    	addSubmissionProgressList(div);
    	
    	List form = div.addList("prefill", List.TYPE_FORM);
        form.setHead(T_head);    
        if (request.getAttribute("identifier.error") != null)
        {
            form.addItem(T_identifier_error);
        }
        if (request.getAttribute("identifier.info") != null)
            {
            form.addItem(T_identifier_info);
            }

            Text DOI = form.addItem().addText("identifier_doi");
            DOI.setLabel(T_doi_label);

            Text pubmedID = form.addItem().addText("identifier_pmid");
            pubmedID.setLabel(T_pmid_label);

            /*Text FactScienceID = form.addItem().addText("identifier_fsid");
            FactScienceID.setLabel(T_fsid_label);*/

            Text PPN = form.addItem().addText("identifier_ppn");
            PPN.setLabel(T_ppn_label);

        //if one of the ids already exists show it and give the possibility to refesh
        if ((pmid != null) && (pmid.length > 0))
        {
            pubmedID.setValue(pmid[0].value);
            div.addHidden("original_pmid").setValue(pmid[0].value);
            fresh = true;
        }
        else if ((doi != null) && (doi.length > 0))
        {
            DOI.setValue(doi[0].value);
            div.addHidden("original_doi").setValue(doi[0].value);
            fresh = true;
        }
        /*else if ((fsid != null) && (fsid.length > 0))
        {
            FactScienceID.setValue(fsid[0].value);
            div.addHidden("original_fsid").setValue(fsid[0].value);
            fresh = true;
        }*/
        else if ((ppn != null) && (ppn.length > 0))
        {
            PPN.setValue(ppn[0].value);
            div.addHidden("original_ppn").setValue(ppn[0].value);
            fresh = true;
        }

        if (fresh)
        {
          CheckBox refresh = form.addItem().addCheckBox("force_refresh");
          refresh.setLabel(T_refresh);
          refresh.addOption("false");
          refresh.setHelp(T_refresh_help);
        }
        else
        {
          form.addItem(T_help);
        }

            //add standard control/paging buttons
            addControlButtons(form);
    }   
	
    
    /** 
     * Each submission step must define its own information to be reviewed
     * during the final Review/Verify Step in the submission process.
     * <P>
     * The information to review should be tacked onto the passed in 
     * List object.
     * <P>
     * NOTE: To remain consistent across all Steps, you should first
     * add a sub-List object (with this step's name as the heading),
     * by using a call to reviewList.addList().   This sublist is
     * the list you return from this method!
     * 
     * @param reviewList
     *      The List to which all reviewable information should be added
     * @return 
     *      The new sub-List object created by this step, which contains
     *      all the reviewable information.  If this step has nothing to
     *      review, then return null!   
     */
    public List addReviewSection(List reviewList) throws SAXException,
        WingException, UIException, SQLException, IOException,
        AuthorizeException
    {

        return null;
    }
}
