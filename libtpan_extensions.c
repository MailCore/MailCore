//
//  libetpan_extensions.c
//  gmailbackup
//
//  Created by David Gelhar on 3/23/13.
//
//  Extensions/bug fixes to libetpan functions.
//

#include "libetpan_extensions.h"

/*
    IMAP "APPEND" operation.
 
    Returns IMAP UID of newly-added message, or a *negative*
    MAILIMAP_* error code on error
 
*/
long gmailimap_append(mailimap * session, const char * mailbox,
		    struct mailimap_flag_list * flag_list,
		    struct mailimap_date_time * date_time,
		    const char * literal, size_t literal_size)
{
    struct mailimap_response * response;
    int r;
    int error_code;
    struct mailimap_continue_req * cont_req;
    size_t indx;
    size_t fixed_literal_size;
    
    if ((session->imap_state != MAILIMAP_STATE_AUTHENTICATED) &&
	(session->imap_state != MAILIMAP_STATE_SELECTED))
	return -MAILIMAP_ERROR_BAD_STATE;
    
    r = mailimap_send_current_tag(session);
    if (r != MAILIMAP_NO_ERROR)
	return -r;
    
    fixed_literal_size = mailstream_get_data_crlf_size(literal, literal_size);
    
    r = mailimap_append_send(session->imap_stream, mailbox, flag_list, date_time,
			     fixed_literal_size);
    if (r != MAILIMAP_NO_ERROR)
	return -r;
    
    if (mailstream_flush(session->imap_stream) == -1)
	return -MAILIMAP_ERROR_STREAM;
    
    if (mailimap_read_line(session) == NULL)
	return -MAILIMAP_ERROR_STREAM;
    
    indx = 0;
    
    r = mailimap_continue_req_parse(session->imap_stream,
				    session->imap_stream_buffer,
				    &indx, &cont_req,
				    session->imap_progr_rate, session->imap_progr_fun);
    if (r == MAILIMAP_NO_ERROR)
	mailimap_continue_req_free(cont_req);
    
    if (r == MAILIMAP_ERROR_PARSE) {
	r = mailimap_parse_response(session, &response);
	if (r != MAILIMAP_NO_ERROR)
	    return -r;
	mailimap_response_free(response);
	
	return -MAILIMAP_ERROR_APPEND;
    }
    
    if (session->imap_body_progress_fun != NULL) {
	r = mailimap_literal_data_send_with_context(session->imap_stream, literal, literal_size,
						    session->imap_body_progress_fun,
						    session->imap_progress_context);
    }
    else {
	r = mailimap_literal_data_send(session->imap_stream, literal, literal_size,
				       session->imap_progr_rate, session->imap_progr_fun);
    }
    if (r != MAILIMAP_NO_ERROR)
	return -r;
    
    r = mailimap_crlf_send(session->imap_stream);
    if (r != MAILIMAP_NO_ERROR)
	return -r;
    
    if (mailstream_flush(session->imap_stream) == -1)
	return -MAILIMAP_ERROR_STREAM;
    
    if (mailimap_read_line(session) == NULL)
	return -MAILIMAP_ERROR_STREAM;
    
    r = mailimap_parse_response(session, &response);
    if (r != MAILIMAP_NO_ERROR)
	return -r;
    
    error_code = response->rsp_resp_done->rsp_data.rsp_tagged->rsp_cond_state->rsp_type;
    mailimap_response_free(response);
    
    switch (error_code) {
	case MAILIMAP_RESP_COND_STATE_OK:
	{
	    clistiter * cur;
	    long imapuid = 0;
	    struct mailimap_extension_data * ext_data;

	    // the APPENDUID extension info is buried in rsp_extension_list
	    for (cur = clist_begin(session->imap_response_info->rsp_extension_list);
		 cur != NULL; cur = clist_next(cur)) {
		
		// Locate UIDPLUS resp code
		ext_data = (struct mailimap_extension_data *) clist_content(cur);
		struct mailimap_uidplus_resp_code_apnd *uidplus_resp = ext_data->ext_data;
		struct mailimap_set *uidset = uidplus_resp->uid_set;	// the uidset is what we care about
		for (clistiter *uidcur = clist_begin(uidset->set_list); uidcur != NULL; uidcur = clist_next(uidcur)) {
		    struct mailimap_set_item *item = clist_content(uidcur);
		    imapuid = item->set_first;		// note - will be only a single result; we did a single append
		}
		
	    }		    
	    return imapuid;
	}
	default:
	    return -MAILIMAP_ERROR_APPEND;
    }
}
